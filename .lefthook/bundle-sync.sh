#!/bin/bash
# Sync gems after git operations that may change Gemfile.lock.

GEMFILE_CHANGED=false

if [[ -n "$LEFTHOOK_GIT_HOOK" ]]; then
  HOOK_NAME="$LEFTHOOK_GIT_HOOK"
else
  HOOK_NAME="unknown"
fi

case "$HOOK_NAME" in
  post-checkout)
    OLD_REF="${1:-}"
    NEW_REF="${2:-}"
    BRANCH_FLAG="${3:-}"
    if [[ "$BRANCH_FLAG" == "0" ]]; then
      exit 0
    fi
    if [[ -n "$OLD_REF" && -n "$NEW_REF" && "$OLD_REF" != "$NEW_REF" ]]; then
      if git diff --name-only "$OLD_REF" "$NEW_REF" 2>/dev/null | grep -q '^Gemfile\.lock$'; then
        GEMFILE_CHANGED=true
      fi
    fi
    ;;
  post-rewrite)
    while read -r OLD_REF NEW_REF _REST; do
      if [[ -n "$OLD_REF" && -n "$NEW_REF" ]]; then
        if git diff --name-only "$OLD_REF" "$NEW_REF" 2>/dev/null | grep -q '^Gemfile\.lock$'; then
          GEMFILE_CHANGED=true
          break
        fi
      fi
    done
    ;;
  post-merge)
    if git diff --name-only HEAD@{1} HEAD 2>/dev/null | grep -q '^Gemfile\.lock$'; then
      GEMFILE_CHANGED=true
    fi
    ;;
  *)
    if git diff --name-only HEAD@{1} HEAD 2>/dev/null | grep -q '^Gemfile\.lock$'; then
      GEMFILE_CHANGED=true
    fi
    ;;
esac

if [[ "$GEMFILE_CHANGED" != true ]]; then
  exit 0
fi

echo "Gemfile.lock changed — syncing gems..." >&2

if ! bundle install; then
  echo "Gem sync failed. Run manually: bundle install" >&2
fi

exit 0
