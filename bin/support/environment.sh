#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "${0} must be sourced, not executed."
  exit 1
fi

if [ -n "$DEBUG" ]; then
  set -x
fi

HAS_LOADED_RMLINT_ENVIRONMENT="yes"
BUILD_DIR=$1
if [ -d "$2" ]; then
  CACHE_DIR="$2/rmlint"
  RMLINT_CACHE_DIR="$2/rmlint"
  mkdir -p "$RMLINT_CACHE_DIR"
fi
ENV_DIR=$3
BUILDPACK_DIR=`cd $(dirname ${BASH_SOURCE[0]})/../..; pwd -P`

RMLINT_VERSION=${RMLINT_VERSION:-v2.9.0}

# load safelist of user config vars
for var in RMLINT_RUN_SCRIPT; do
  [ -f "$ENV_DIR/$var" ] && declare $var="$(cat $ENV_DIR/$var)"
done

function echo()
{
  echo_cmd=`which echo`
  if [[ "Darwin" == "$(uname)" ]] && command -v gecho >/dev/null 2>&1; then
    echo_cmd=`which gecho`
  fi
  $echo_cmd $*
}

function indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

function topic() {
  echo "-----> $*"
}

function warn() {
  local IFS=
  echo -e "\e[1m\e[33m###### WARNING:\e[0m" # Bold yellow
  echo ""
  echo -e "$*" | while read -r line; do
    echo "       $line"
  done
}

function error() {
  local IFS=
  echo -n -e "\e[1m\e[31m" # Bold Red
  echo " !"
  echo -e "$*" | while read -r line; do
    echo " !     $line"
  done
  echo -e " !\e[0m"
  exit 1
}
