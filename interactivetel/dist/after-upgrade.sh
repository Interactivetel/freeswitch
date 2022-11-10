#!/bin/sh

echo
echo "######################################################################"
echo "::: FreeSWITCH: Recreating symlinks for: fs_cli and freeswitch"
echo "######################################################################"
echo

test -e /usr/local/bin/freeswitch || ln -sf /usr/local/freeswitch/bin/freeswitch /usr/local/bin/freeswitch
test -e /usr/local/bin/fs_cli || ln -sf /usr/local/freeswitch/bin/fs_cli /usr/local/bin/fs_cli


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
