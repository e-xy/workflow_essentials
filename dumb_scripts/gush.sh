#!/usr/bin/env bash

set -euo pipefail

# ── colors ────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED=$'\e[31m'; GRN=$'\e[32m'; YLW=$'\e[33m'; CYN=$'\e[36m'
    BLD=$'\e[1m';  RST=$'\e[0m'
else
    RED=; GRN=; YLW=; CYN=; BLD=; RST=
fi
die()  { printf '%s✗ %s%s\n' "$RED" "$1" "$RST" >&2; exit 1; }
info() { printf '%s→ %s%s\n' "$CYN" "$1" "$RST"; }
ok()   { printf '%s✓ %s%s\n' "$GRN" "$1" "$RST"; }
warn() { printf '%s! %s%s\n' "$YLW" "$1" "$RST"; }

# ── preflight ─────────────────────────────────────────────────────────────────
git rev-parse --git-dir >/dev/null 2>&1 || die "not a git repository"
command -v fzf >/dev/null 2>&1           || die "fzf is not installed"

# ── stage ─────────────────────────────────────────────────────────────────────
changes=$(git status --porcelain)
[[ -z "$changes" ]] && { ok "working tree clean — nothing to do"; exit 0; }

# preview: diff for tracked changes, file contents for untracked
preview_cmd='
line={}
status=${line:0:2}
file=${line:3}
file=${file#\"}; file=${file%\"}
[[ "$status" == R* ]] && file=${file##* -> }

if [[ "$status" == "??" ]]; then
    printf "\033[33m[untracked]\033[0m %s\n\n" "$file"
    if command -v bat >/dev/null 2>&1; then
        bat --color=always --style=numbers --line-range=:200 "$file" 2>/dev/null
    elif [[ -f "$file" ]]; then
        head -200 "$file"
    fi
else
    git diff --color=always HEAD -- "$file" | head -400
fi
'

selected=$(echo "$changes" | fzf -m \
    --ansi \
    --header=$'TAB: multi-select   ENTER: confirm   ESC: abort' \
    --preview="$preview_cmd" \
    --preview-window=right:60%:wrap \
    --height=80% \
    --border=rounded \
    --prompt='stage › ') || die "aborted"

[[ -z "$selected" ]] && die "no files selected"

while IFS= read -r line; do
    file=${line:3}
    file=${file#\"}; file=${file%\"}
    [[ "${line:0:2}" == R* ]] && file=${file##* -> }
    git add -- "$file"
    printf '  %s+%s %s\n' "$GRN" "$RST" "$file"
done <<< "$selected"

echo
info "staged:"
git diff --cached --stat | sed 's/^/  /'
echo

# ── commit ────────────────────────────────────────────────────────────────────
printf '%scommit message%s (blank to open $EDITOR): ' "$BLD" "$RST"
read -r msg
if [[ -z "$msg" ]]; then
    git commit || { warn "commit aborted — changes remain staged"; exit 1; }
else
    git commit -m "$msg"
fi

# ── push ──────────────────────────────────────────────────────────────────────
remotes=$(git remote)
if [[ -z "$remotes" ]]; then
    warn "no remotes configured — commit kept locally"
    exit 0
fi

remote=$(printf '%s\n[skip push]\n' "$remotes" | fzf \
    --header='select remote to push to' \
    --preview='[[ {} != "[skip push]" ]] && git remote get-url {} 2>/dev/null' \
    --preview-window=down:3:wrap \
    --height=40% \
    --border=rounded \
    --prompt='remote › ') || { info "skipping push"; exit 0; }

[[ "$remote" == "[skip push]" ]] && { info "skipping push"; exit 0; }

current=$(git symbolic-ref --short HEAD)
branches=$(
    printf '%s\n' "$current"
    git branch --format='%(refname:short)' | grep -vFx "$current" || true
)

branch=$(echo "$branches" | fzf \
    --header="select branch (current: $current)" \
    --height=40% \
    --border=rounded \
    --prompt='branch › ') || { info "skipping push"; exit 0; }

echo
info "pushing $branch → $remote"
if git push "$remote" "$branch"; then
    ok "pushed."
else
    warn "push failed — try: git push -u $remote $branch"
fi
