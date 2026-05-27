#!/usr/bin/env bats
#
# `-v` / `--verbose` echoes each mutagen invocation. It must work both
# before and after the subcommand, and it must not leak the trace into
# stdout captured by command substitution inside ferment itself.

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

@test "-v before subcommand traces mutagen call" {
  run_ferment -v flush
  [ "$status" -eq 0 ]
  [[ "$output" == *"mutagen sync flush --all"* ]]
}

@test "--verbose after subcommand also traces" {
  run_ferment flush --verbose
  [ "$status" -eq 0 ]
  [[ "$output" == *"mutagen sync flush --all"* ]]
}

@test "without -v no trace line is emitted" {
  run_ferment flush
  [ "$status" -eq 0 ]
  [[ "$output" != *"$ mutagen"* ]]
}

@test "-v does not pollute stdout that ferment parses (st still works)" {
  run_ferment -v st
  [ "$status" -eq 0 ]
  [[ "$output" == *"myproj-code"* ]]
  [[ "$output" == *"mutagen sync list --template"* ]]
}
