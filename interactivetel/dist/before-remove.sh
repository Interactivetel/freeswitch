#!/bin/sh

if ! pgrep freeswitch > /dev/null 2>&1; then
  echo "FreeSWITCH is not running, nothing to do!"
  exit 0
fi

SUPERVISORCTL=$(command -v supervisorctl)
if [[ -n "$SUPERVISORCTL" ]]; then
  if "$SUPERVISORCTL" status freeswitch >/dev/null 2>&1; then
    echo "Detected FreeSWITCH running under supervisord ..."
    "$SUPERVISORCTL" stop freeswitch
  fi
fi

rm -f /usr/local/bin/freeswitch
rm -f /usr/local/bin/fs_cli

exit 0