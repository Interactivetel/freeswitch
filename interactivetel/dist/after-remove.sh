#!/bin/sh

echo "::: FreeSWITCH: Running after-remove with args: $*"

echo "::: FreeSWITCH: Removing symlinks for: fs_cli and freeswitch"
rm -f /usr/local/bin/freeswitch
rm -f /usr/local/bin/fs_cli

echo "::: FreeSWITCH: Removing daily cron job to clear debug cdr files"
rm -f /etc/cron.daily/freeswitch-clean-debug-cdr

echo