#!/bin/sh

echo
echo "######################################################################"
echo "::: FreeSWITCH: Creating symlinks for: fs_cli and freeswitch"
echo "######################################################################"
echo

test -e /usr/local/bin/freeswitch || ln -sf /usr/local/freeswitch/bin/freeswitch /usr/local/bin/freeswitch
test -e /usr/local/bin/fs_cli || ln -sf /usr/local/freeswitch/bin/fs_cli /usr/local/bin/fs_cli
