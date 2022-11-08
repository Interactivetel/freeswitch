#!/usr/bin/env bash
set -eE
cd "$(dirname "$0")"

. lib.sh

system-detect
install-default-repos
install-custom-repos
