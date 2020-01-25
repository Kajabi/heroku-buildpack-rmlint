#!/usr/bin/env bash
# bin/support/install-rmlint <build-dir> <cache-dir> <env-dir>

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "${0} must be sourced, not executed."
  exit 1
fi

if [ -z "$HAS_LOADED_RMLINT_ENVIRONMENT" ]; then
  echo "${0} must be sourced after bin/support/environment.sh"
  exit 1
fi

function install_rmlint()
{
  local src_dir="$RMLINT_CACHE_DIR/src/rmlint-$RMLINT_VERSION"

  if ! [ -d $src_dir ] || ! git -C $src_dir rev-parse --verify $RMLINT_VERSION; then
    rm -rf $src_dir
    mkdir -p $src_dir
    topic "Cloning https://github.com/sahib/rmlint.git#$RMLINT_VERSION ..."

    git clone -c advice.detachedHead= -b $RMLINT_VERSION --depth 1 https://github.com/sahib/rmlint.git $src_dir
  fi

  cd $src_dir

  if ! ([ -f rmlint ] && ./rmlint --version); then
    topic "Building rmlint ..."

    scons config --prefix="$BUILD_DIR/.apt/usr"
    scons --prefix="$BUILD_DIR/.apt/usr"
  fi

  mkdir -p "$RMLINT_CACHE_DIR/bin"
  ln -f -s "$src_dir/rmlint" "$RMLINT_CACHE_DIR/bin/rmlint"
}
install_rmlint
