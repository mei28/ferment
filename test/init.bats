#!/usr/bin/env bats

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

@test "init creates mutagen.yml in cwd" {
  run_ferment init
  [ "$status" -eq 0 ]
  [ -f "mutagen.yml" ]
}

@test "init uses given project name" {
  run_ferment init my-special-project
  [ "$status" -eq 0 ]
  grep -q "my-special-project" mutagen.yml
}

@test "init defaults to basename of cwd" {
  # `WORKDIR`'s basename is "work" (see helpers/common.bash)
  run_ferment init
  [ "$status" -eq 0 ]
  grep -q "mutagen project: work" mutagen.yml
}

@test "init refuses to overwrite an existing mutagen.yml" {
  : > mutagen.yml
  run_ferment init
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]
}

@test "init refuses when mutagen.yaml exists" {
  : > mutagen.yaml
  run_ferment init
  [ "$status" -ne 0 ]
  [[ "$output" == *"already exists"* ]]
}

@test "generated mutagen.yml carries the expected schema bones" {
  run_ferment init demo
  [ "$status" -eq 0 ]
  grep -q "^sync:"                          mutagen.yml
  grep -q "mode: two-way-resolved"          mutagen.yml
  grep -q "vcs: true"                       mutagen.yml
  grep -q "flushOnCreate: true"             mutagen.yml
  grep -q "demo-code:"                      mutagen.yml
}
