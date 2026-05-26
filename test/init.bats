#!/usr/bin/env bats

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

@test "init creates ferment.yml in cwd" {
  run_ferment init
  [ "$status" -eq 0 ]
  [ -f "ferment.yml" ]
}

@test "init uses given project name" {
  run_ferment init my-special-project
  [ "$status" -eq 0 ]
  grep -q "my-special-project" ferment.yml
}

@test "init defaults to basename of cwd" {
  # `WORKDIR`'s basename is "work" (see helpers/common.bash)
  run_ferment init
  [ "$status" -eq 0 ]
  grep -q "ferment project: work" ferment.yml
}

@test "init refuses to overwrite an existing ferment.yml" {
  : > ferment.yml
  run_ferment init
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]
}

@test "init refuses when mutagen.yml exists (compat path)" {
  : > mutagen.yml
  run_ferment init
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]
}

@test "generated ferment.yml carries the expected schema bones" {
  run_ferment init demo
  [ "$status" -eq 0 ]
  grep -q "^sync:"                          ferment.yml
  grep -q "mode: two-way-resolved"          ferment.yml
  grep -q "vcs: true"                       ferment.yml
  grep -q "flushOnCreate: true"             ferment.yml
  grep -q "demo-code:"                      ferment.yml
}
