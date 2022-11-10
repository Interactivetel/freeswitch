#!/bin/sh

echo
echo "######################################################################"
echo "::: FreeSWITCH: Purging config files"
echo "######################################################################"
echo

if [ -d /usr/local/freeswitch ]; then
  echo "Found leftover config directory, removing it: /usr/local/freeswitch"
  rm -rf /usr/local/freeswitch
fi

