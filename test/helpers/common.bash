# Shared setup for ferment bats tests.
#
# Each test gets its own temp dir on PATH that contains the stub mutagen,
# and `cd`s into a separate working dir so `ferment init` etc. cannot
# escape the sandbox.

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
FERMENT="${REPO_ROOT}/bin/ferment"
STUB_SRC="${REPO_ROOT}/test/helpers/mutagen-stub"

ferment_setup() {
  TEST_TMP="$(mktemp -d "${BATS_TMPDIR:-/tmp}/ferment.XXXXXX")"
  STUB_BIN="${TEST_TMP}/bin"
  WORKDIR="${TEST_TMP}/work"
  mkdir -p "$STUB_BIN" "$WORKDIR"

  install -m 0755 "$STUB_SRC" "$STUB_BIN/mutagen"

  export STUB_MUTAGEN_LOG="${TEST_TMP}/mutagen.log"
  : > "$STUB_MUTAGEN_LOG"

  PATH="$STUB_BIN:$PATH"
  export PATH
  export NO_COLOR=1   # keep assertions free of ANSI noise

  cd "$WORKDIR"
}

ferment_teardown() {
  if [ -n "${TEST_TMP:-}" ] && [ -d "$TEST_TMP" ]; then
    rm -rf "$TEST_TMP"
  fi
}

# Convenience: run ferment with the stub PATH already in place.
run_ferment() {
  run "$FERMENT" "$@"
}
