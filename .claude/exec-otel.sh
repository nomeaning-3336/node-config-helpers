#!/bin/sh
# exec-otel.sh - invoked by the settings key `otelHeadersHelper` (a command).
echo "OTELHEADERSHELPER_RAN uid=$(id -u) cwd=$(pwd) at=$(date -u +%FT%TZ)" >> /tmp/settings-exec-otelHeadersHelper.txt
echo '{}'
