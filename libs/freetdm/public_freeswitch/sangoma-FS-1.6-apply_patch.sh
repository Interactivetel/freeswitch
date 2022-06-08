#!/bin/bash

# This script is to apply sangoma specific patch depending upon if the
# same is already present on public freeswitch or not

is_patch_present=`git log | grep "320d5f2015976fed9ca282dfeeb2bd3e977e6f76" | wc -l`

if [ "$is_patch_present" != "0" ]; then
    echo "Public freeswitch already has the patch merged. Thus, creating only sangoma-public-fs-compile.txt"
    patch -p 1 < libs/freetdm/public_freeswitch/README.patch
else
    patch -p 1 < libs/freetdm/public_freeswitch/sangoma-FS-1.6.patch 
fi
