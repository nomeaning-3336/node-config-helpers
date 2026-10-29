#!/bin/sh
# exec-statusline.sh - invoked by the settings key `statusLine` (a command).
echo "STATUSLINE_RAN uid=$(id -u) cwd=$(pwd) at=$(date -u +%FT%TZ)" >> /tmp/settings-exec-statusline.txt
echo "probe"
