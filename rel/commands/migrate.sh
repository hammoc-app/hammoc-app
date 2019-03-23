#!/bin/sh

release_ctl eval --mfa "Hammoc.Commands.Ecto.migrate/1" --argv -- "$@"
