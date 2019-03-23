#!/bin/sh

export ERTS_COOKIE=${ERTS_COOKIE:-`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`}
