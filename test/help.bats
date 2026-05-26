#!/usr/bin/env bats

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

@test "no args prints help" {
  run_ferment
  [ "$status" -eq 0 ]
  [[ "$output" == *"ferment"* ]]
  [[ "$output" == *"Usage:"* ]]
}

@test "help subcommand prints help" {
  run_ferment help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "-h / --help are aliases of help" {
  run_ferment -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]

  run_ferment --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "version subcommand prints version" {
  run_ferment version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ferment"* ]]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "-V / --version are aliases of version" {
  run_ferment -V
  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]

  run_ferment --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "unknown subcommand exits non-zero with hint" {
  run_ferment nope-not-a-command
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown subcommand"* ]]
}
