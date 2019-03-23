% originally based on https://gist.github.com/maxlapshin/01773f0fca706acdcb4acb77d91d78bb

-module(systemd).
% This is what you need to adopt systemd in erlang

-export([ready/1, reloading/1, stopping/1, watchdog/1]).

-export([start_link/0]).
-export([init/1, handle_info/2, terminate/2]).

ready(Path) -> call(Path, <<"READY=1">>).
reloading(Path) -> call(Path, <<"RELOADING=1">>).
stopping(Path) -> call(Path, <<"STOPPING=1">>).
watchdog(Path) -> call(Path, <<"WATCHDOG=1">>).

call(Path, Call) ->
  case gen_udp:open(0, [local]) of
    {error, SocketError} ->
      logger:error("Could not open NOTIFY_SOCKET: ~p", [SocketError]),
      {error, SocketError};

    {ok, Socket} ->
      Result = gen_udp:send(Socket, {local, Path}, 0, Call),
      gen_udp:close(Socket),
      case Result of
        {error, SendError} ->
          logger:error("Could not send via NOTIFY_SOCKET: ~p", [SendError]),
          Result;

        _ -> Result
      end
  end.

start_link() ->
  gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

init([]) ->
  case os:getenv("NOTIFY_SOCKET") of
    false ->
      logger:debug("NOTIFY_SOCKET is not set."),
      {ok, state};

    Path ->
      logger:info("NOTIFY_SOCKET is ~p. Sending READY=1 message.", [Path]),
      erlang:send(self(), ready),
      case os:getenv("WATCHDOG_USEC") of
        false ->
          logger:debug("WATCHDOG_USEC is not set."),
          {ok, {Path, false}};

        UsecStr ->
          {Usec, _} = string:to_integer(UsecStr),
          MsecHalf = Usec div 2000,
          logger:info("WATCHDOG_USEC is ~p. Sending WATCHDOG=1 messages every ~ps.", [Usec, MsecHalf div 1000]),
          erlang:send(self(), watchdog),
          {ok, {Path, MsecHalf}}
      end
  end.

handle_info(ready, State = {Path, _}) ->
  ok = ready(Path),
  {noreply, State};

handle_info(watchdog, State = {Path, MsecHalf}) ->
  erlang:send_after(MsecHalf, self(), watchdog),
  ok = watchdog(Path),
  {noreply, State}.

terminate(_, {Path, _}) ->
  ok = stopping(Path),
  ok.
