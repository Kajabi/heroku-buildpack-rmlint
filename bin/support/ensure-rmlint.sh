#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "${0} must be sourced, not executed."
  exit 1
fi

if [ -z "$HAS_LOADED_RMLINT_ENVIRONMENT" ]; then
  echo "${0} must be sourced after bin/support/environment.sh"
  exit 1
fi

function ensure_rmlint_installation()
{
  # Read the cached STACK and overwrite it with the current one
  CACHED_STACK=$(cat "$RMLINT_CACHE_DIR/STACK" 2>/dev/null || echo $STACK)
  echo "$STACK" > "$RMLINT_CACHE_DIR/STACK"

  if [ -x "$RMLINT_CACHE_DIR/bin/rmlint" ] && [[ "$CACHED_STACK" == "$STACK" ]]; then
    # rmlint is installed and STACK has not changed
    topic "Reusing cached rmlint."
  else
    if [[ "$CACHED_STACK" != "$STACK" ]]; then
      topic "Detected stack changes, flushing cache"
      rm -rf $RMLINT_CACHE_DIR
      mkdir -p $RMLINT_CACHE_DIR
    fi

    topic "Installing rmlint and dependencies"
    source $BUILDPACK_DIR/bin/support/install-deps.sh
    source $BUILDPACK_DIR/bin/support/install-rmlint.sh
  fi

  export PATH="$RMLINT_CACHE_DIR/bin:$PATH"
}
ensure_rmlint_installation
