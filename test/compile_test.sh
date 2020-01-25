#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testCompile() {
  loadFixture "basic"

  compile

  assertCapturedSuccess
}

testStackChange() {
  loadFixture "basic"
  #Set the cached STACK value to a non-existent stack, so it is guaranteed to change.
  mkdir -p "$CACHE_DIR/rmlint/"
  echo "cedar-10" > "$CACHE_DIR/rmlint/STACK"

  compile

  assertCapturedSuccess
  assertCaptured "Detected Stack changes, flushing cache"
}

testStackNoChange() {
  loadFixture "basic"
  stubRmlintBin
  mkdir -p "$CACHE_DIR/rmlint/"
  echo "$STACK" > "$CACHE_DIR/rmlint/STACK"

  compile

  assertCaptured "Reusing cached rmlint."
}

testStackCached() {
  loadFixture "basic"
  stubRmlintBin

  compile

  assertCapturedSuccess
  assertTrue 'STACK not cached' "[ -e $CACHE_DIR/rmlint/STACK ]"
}

stubRmlintBin() {
  mkdir -p "$CACHE_DIR/rmlint/bin"
  touch "$CACHE_DIR/rmlint/bin/rmlint"
  chmod +x "$CACHE_DIR/rmlint/bin/rmlint"
}

loadFixture() {
  cp -a $BUILDPACK_HOME/test/fixtures/$1/. ${BUILD_DIR}
}
