#!/bin/sh

echo "::: FreeSWITCH: Running after-purge with args: $*"

if [ -d /usr/local/freeswitch ]; then
  echo "Found leftover config directory, removing it: /usr/local/freeswitch"
  rm -rf /usr/local/freeswitch
fi

echo
