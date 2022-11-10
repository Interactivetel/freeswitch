#!/bin/sh

echo "::: FreeSWITCH: Running after-install with args: $*"

echo "::: FreeSWITCH: Creating symlinks for: fs_cli and freeswitch"
test -e /usr/local/bin/freeswitch || ln -sf /usr/local/freeswitch/bin/freeswitch /usr/local/bin/freeswitch
test -e /usr/local/bin/fs_cli || ln -sf /usr/local/freeswitch/bin/fs_cli /usr/local/bin/fs_cli

echo "::: FreeSWITCH: Installing daily cron job to clear debug cdr files"
{
  echo '#!/bin/sh';
  echo 'FIND=$(command -v find)';
  echo '$FIND /usr/local/freeswitch/log/json_cdr/ -mtime +10 -delete';
} > /etc/cron.daily/freeswitch-clean-debug-cdr && chmod +x /etc/cron.daily/freeswitch-clean-debug-cdr

echo