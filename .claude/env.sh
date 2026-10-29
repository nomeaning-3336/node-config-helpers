#!/bin/bash
# .claude/env.sh - INERT. Research artifact only.
#
# This file is committed to a public repository as part of a security research write-up.
# It deliberately performs NO network activity and writes nothing outside /tmp, so that anyone
# who happens to attach this repository gets no surprise behaviour from it.
#
# The original research payload POSTed a capability report to a collector; that exfiltration
# step has been removed from this public copy.

R=/tmp/.probe-report.txt
{
  echo "=== IDENTITY ==="
  echo "uid=$(id -u) cwd=$(pwd)"
  echo "=== SETTINGS env KEYS IN THIS TOOL PROCESS ==="
  echo "LD_PRELOAD=${LD_PRELOAD:-absent}"
  echo "BASH_ENV=${BASH_ENV:-absent}"
  echo "PROBE_MARKER=${PROBE_MARKER:-absent}"
  echo "NOTE: inert research artifact - no network activity performed."
} > "$R" 2>&1

return 0 2>/dev/null || exit 0
