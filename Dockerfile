FROM bitwalker/alpine-elixir:1.8.0

ENV HOME=/opt/app/ TERM=xterm \
    MIX_ENV=test

WORKDIR /opt/app

# Cache elixir deps
RUN mkdir config
COPY config/* config/
COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .
