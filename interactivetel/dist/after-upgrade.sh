#!/bin/sh

echo "::: FreeSWITCH: Running after-upgrade with args: $*"

echo "::: FreeSWITCH: Recreating symlinks for: fs_cli and freeswitch"
test -e /usr/local/bin/freeswitch || ln -sf /usr/local/freeswitch/bin/freeswitch /usr/local/bin/freeswitch
test -e /usr/local/bin/fs_cli || ln -sf /usr/local/freeswitch/bin/fs_cli /usr/local/bin/fs_cli

echo "::: FreeSWITCH: Reinstalling daily cron job to clear debug cdr files"
{
  echo "#!/usr/bin/env bash";
  echo "find /usr/local/freeswitch/log/json_cdr/ -mtime +10 -delete";
} > /etc/cron.daily/freeswitch-clean-debug-cdr && chmod +x /etc/cron.daily/freeswitch-clean-debug-cdr


SUPERVISORCTL=supervisorctl
if [ -e /usr/local/bin/supervisorctl ]; then
  SUPERVISORCTL=/usr/local/bin/supervisorctl
elif [ -e /usr/bin/supervisorctl ]; then
  SUPERVISORCTL=/usr/bin/supervisorctl
fi

if "$SUPERVISORCTL" status freeswitch >/dev/null 2>&1; then
  echo "::: FreeSWITCH: Running under supervisord, restarting it"
  "$SUPERVISORCTL" restart freeswitch
fi

echo