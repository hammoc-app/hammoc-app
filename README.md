# [Hammoc](https://hammoc.app/)

[![Build Status](https://travis-ci.com/hammoc-app/hammoc-app.svg?branch=master)](https://travis-ci.com/hammoc-app/hammoc-app)
|
[Docs](https://docs.hammoc.app/)
|
[Code Coverage](https://docs.hammoc.app/excoveralls.html)

[<img src="https://hammoc.app/images/hammoc.svg" alt="Hammoc Logo" width="50%"/>](https://hammoc.app/)

Hammoc lets you add all links you shared, bookmarked or liked in your various accounts to one collection.
Easily find links again, with all the context, or get the Top 5 links every week via e-mail or mobile notification.


## Dev setup

### Elixir & Erlang

We recommend installing *Elixir via asdf*, an extendable version manager for Elixir, Erlang & others:

* Follow [asdf's instructions](https://github.com/asdf-vm/asdf) for installation
* From project root dir, run:
  ```
  asdf install
  ```

### Docker

We recommend using [Docker](https://www.docker.com/) to run the database.

On macOS, install [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/).

On Ubuntu, install the [`docker-ce` apt package](https://docs.docker.com/install/linux/docker-ce/ubuntu/).


## Develop & test

To start the server:

  * Start the database in the background with `docker-compose up -d`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install && cd -`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Learn more

  * Official Elixir website: https://elixir-lang.org/
  * Phoenix, the web framework Hammoc is using
    * Official website: http://www.phoenixframework.org/
    * Guides: https://hexdocs.pm/phoenix/overview.html
    * Docs: https://hexdocs.pm/phoenix
    * Mailing list: http://groups.google.com/group/phoenix-talk
    * Source: https://github.com/phoenixframework/phoenix
