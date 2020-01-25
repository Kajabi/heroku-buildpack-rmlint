#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "${0} must be sourced, not executed."
  exit 1
fi

if [ -z "$HAS_LOADED_RMLINT_ENVIRONMENT" ]; then
  echo "${0} must be sourced after bin/support/environment.sh"
  exit 1
fi

function install_deps()
{
  # Setup apt environment
  local apt_dir="$CACHE_DIR/apt"
  mkdir -p "$apt_dir"

  local apt_cache_dir="$CACHE_DIR/apt/cache"
  local apt_state_dir="$CACHE_DIR/apt/state"
  local apt_sourcelist_dir="$CACHE_DIR/apt/sources"
  local apt_sources="$apt_sourcelist_dir/sources.list"

  mkdir -p "$apt_cache_dir/archives/partial"
  mkdir -p "$apt_state_dir/lists/partial"
  mkdir -p "$apt_sourcelist_dir"

  if ! [ -f "$apt_source" ]; then
    cat "/etc/apt/sources.list" > "$apt_sources"
  fi

  local apt_version=$(apt-get -v | awk 'NR == 1{ print $2 }')
  local apt_force_yes=
  case "$apt_version" in
    0* | 1.0*) apt_force_yes="--force-yes";;
    *)         apt_force_yes="--allow-downgrades --allow-remove-essential --allow-change-held-packages";;
  esac
  local apt_options="-o debug::nolocking=true -o dir::cache=$apt_cache_dir -o dir::state=$apt_state_dir"
  # Override the use of /etc/apt/sources.list (sourcelist) and /etc/apt/sources.list.d/* (sourceparts).
  local apt_options="$apt_options -o dir::etc::sourcelist=$apt_sources -o dir::etc::sourceparts=/dev/null"

  echo "Updating apt caches for dependencies" | indent

  apt-get $apt_options update | indent

  echo "Installing dependencies..." | indent
  local deps=$(cat $BUILDPACK_DIR/Aptfile | grep -v -s -e '^#' | xargs)

  apt-get $apt_options -y $apt_force_yes -d install --reinstall $deps | indent

  local deps_ary=
  IFS=" " read -a deps_ary <<< "$deps"
  local dep=
  for dep in "${deps_ary[@]}"; do
    echo "Installing $dep" | indent
    ls -t "$apt_cache_dir"/archives/"$dep"*.deb | xargs -i dpkg -x '{}' "$apt_dir" | indent
  done

  export PATH="$apt_dir/usr/bin:$PATH"
}
install_deps
