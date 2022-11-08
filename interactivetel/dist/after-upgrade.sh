#!/bin/sh

SUPERVISORCTL=supervisorctl
if [ -e /usr/local/bin/supervisorctl ]; then
  SUPERVISORCTL=/usr/local/bin/supervisorctl
elif [ -e /usr/bin/supervisorctl ]; then
  SUPERVISORCTL=/usr/bin/supervisorctl
fi

if "$SUPERVISORCTL" status freeswitch >/dev/null 2>&1; then
  echo
  echo "######################################################################"
  echo "::: FreeSWITCH: Running under supervisord, restarting it"
  echo "######################################################################"
  echo
  "$SUPERVISORCTL" restart freeswitch
fi
