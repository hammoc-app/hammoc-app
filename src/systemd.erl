% originally based on https://gist.github.com/maxlapshin/01773f0fca706acdcb4acb77d91d78bb

-module(systemd).
% This is what you need to adopt systemd in erlang

-export([ready/0, reloading/0, stopping/0, watchdog/0]).

-export([start_link/0]).
-export([init/1, handle_info/2, terminate/2]).


ready() -> call(<<"READY=1">>).
reloading() ->call(<<"RELOADING=1">>).
stopping() -> call(<<"STOPPING=1">>).
watchdog() -> call(<<"WATCHDOG=1">>).


call(Call) ->
  case os:getenv("NOTIFY_SOCKET") of
    false ->
      {error, not_configured};
    Path ->
      case gen_udp:open(0, [local]) of
        {error, SocketError} ->
          {error, SocketError};
        {ok, Socket} ->
          Result = gen_udp:send(Socket, {local,Path}, 0, Call),
          gen_udp:close(Socket),
          Result
      end
  end.


start_link() ->
  gen_server:start_link({local,?MODULE}, ?MODULE, [], []).


init([]) ->
  ready(),
  erlang:send_after(60000, self(), watchdog),
  {ok, state}.


handle_info(watchdog, State) ->
  watchdog(),
  erlang:send_after(60000, self(), watchdog),
  {noreply, State}.

terminate(_,_) ->
  stopping(),
  ok.
