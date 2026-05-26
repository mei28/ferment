#!/usr/bin/env bats
#
# Covers cmd_st's template parsing and fall-backs.

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

@test "st renders session rows from the templated output" {
  run_ferment st
  [ "$status" -eq 0 ]
  [[ "$output" == *"NAME"* ]]
  [[ "$output" == *"myproj-code"* ]]
  [[ "$output" == *"myproj-assets"* ]]
  [[ "$output" == *"Watching for changes"* ]]
  [[ "$output" == *"Disconnected"* ]]
}

@test "st surfaces conflict count from template" {
  run_ferment st
  [ "$status" -eq 0 ]
  # myproj-assets has 1 conflict in the canned output
  [[ "$output" == *"1"* ]]
}

@test "st warns when there are no sessions" {
  STUB_MUTAGEN_MODE=empty run_ferment st
  [ "$status" -eq 0 ]
  [[ "$output" == *"no sync sessions"* ]]
}

@test "st falls back when --template isn't supported" {
  STUB_MUTAGEN_MODE=unsupported run_ferment st
  [ "$status" -eq 0 ]
  [[ "$output" == *"falling back to raw output"* ]]
  [[ "$output" == *"myproj-code"* ]]
}

@test "status / ls / list are aliases of st" {
  for alias in status ls list; do
    run_ferment "$alias"
    [ "$status" -eq 0 ]
    [[ "$output" == *"myproj-code"* ]]
  done
}
