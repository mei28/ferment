#!/usr/bin/env bats
#
# Verifies that aliases route to the right `cmd_*` function by inspecting
# the stub mutagen's call log.

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

last_call() {
  tail -n 1 "$STUB_MUTAGEN_LOG"
}

@test "flush with no args forwards --all" {
  run_ferment flush
  [ "$status" -eq 0 ]
  [[ "$(last_call)" == "sync flush --all" ]]
}

@test "flush <session> passes session through" {
  run_ferment flush my-session
  [ "$status" -eq 0 ]
  [[ "$(last_call)" == "sync flush my-session" ]]
}

@test "pause / resume / reset share the flush dispatch shape" {
  run_ferment pause
  [[ "$(last_call)" == "sync pause --all" ]]

  run_ferment resume
  [[ "$(last_call)" == "sync resume --all" ]]

  run_ferment reset
  [[ "$(last_call)" == "sync reset --all" ]]
}

@test "f and sync are aliases of flush" {
  run_ferment f
  [[ "$(last_call)" == "sync flush --all" ]]

  run_ferment sync
  [[ "$(last_call)" == "sync flush --all" ]]
}

@test "up requires a project file" {
  run_ferment up
  [ "$status" -ne 0 ]
  [[ "$output" == *"no project file"* ]]
}

@test "up forwards --project-file for ferment.yml" {
  run_ferment init demo
  [ "$status" -eq 0 ]

  run_ferment up
  [ "$status" -eq 0 ]
  grep -q "project start --project-file ferment.yml" "$STUB_MUTAGEN_LOG"
}

@test "up omits --project-file when mutagen.yml is present" {
  : > mutagen.yml
  run_ferment up
  [ "$status" -eq 0 ]
  grep -q "^project start$" "$STUB_MUTAGEN_LOG"
}

@test "down forwards terminate (no project file -> no flag)" {
  run_ferment down
  [ "$status" -eq 0 ]
  grep -q "^project terminate$" "$STUB_MUTAGEN_LOG"
}

@test "down forwards --project-file for ferment.yml" {
  run_ferment init demo
  run_ferment down
  [ "$status" -eq 0 ]
  grep -q "project terminate --project-file ferment.yml" "$STUB_MUTAGEN_LOG"
}

@test "why forwards --long and any extra args" {
  run_ferment why my-session
  [ "$status" -eq 0 ]
  [[ "$(last_call)" == "sync list --long my-session" ]]
}

@test "daemon delegates to mutagen daemon status" {
  run_ferment daemon
  [ "$status" -eq 0 ]
  [[ "$(last_call)" == "daemon status" ]]
}
