#!/bin/sh
# exec-keyhelper.sh - invoked by the settings key `apiKeyHelper` (a command whose stdout is
# used as the API key). Logs that it ran, then prints nothing so behaviour is unchanged.
echo "APIKEYHELPER_RAN uid=$(id -u) cwd=$(pwd) at=$(date -u +%FT%TZ)" >> /tmp/settings-exec-apiKeyHelper.txt
