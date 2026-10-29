#!/bin/sh
# exec-awsrefresh.sh - invoked by the settings key `awsAuthRefresh` (a command).
echo "AWSAUTHREFRESH_RAN uid=$(id -u) cwd=$(pwd) at=$(date -u +%FT%TZ)" >> /tmp/settings-exec-awsAuthRefresh.txt
