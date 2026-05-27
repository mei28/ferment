#!/usr/bin/env bats
#
# `ferment completion <shell>` emits a ready-to-source script for each
# supported shell. The output must match what the static files under
# completions/ ship (i.e. the script is the source of truth).

load helpers/common

setup()    { ferment_setup; }
teardown() { ferment_teardown; }

@test "completion bash emits a bash completion script" {
  run_ferment completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"complete -F _ferment ferment"* ]]
  [[ "$output" == *"_ferment()"* ]]
}

@test "completion zsh emits a zsh completion script" {
  run_ferment completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"#compdef ferment"* ]]
  [[ "$output" == *"_describe"* ]]
}

@test "completion fish emits a fish completion script" {
  run_ferment completion fish
  [ "$status" -eq 0 ]
  [[ "$output" == *"complete -c ferment"* ]]
  [[ "$output" == *"__fish_use_subcommand"* ]]
}

@test "completion without a shell name errors" {
  run_ferment completion
  [ "$status" -ne 0 ]
  [[ "$output" == *"missing shell"* ]]
}

@test "completion with unknown shell errors" {
  run_ferment completion powershell
  [ "$status" -ne 0 ]
  [[ "$output" == *"unsupported shell"* ]]
}

@test "completion works without mutagen on PATH" {
  # Strip the stub bin from PATH so mutagen really is missing.
  PATH="${PATH#${STUB_BIN}:}"
  run "$FERMENT" completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"complete -F _ferment ferment"* ]]
}

@test "static completion files stay in sync with the embedded source" {
  local generated expected
  for shell in bash zsh fish; do
    case "$shell" in
      bash) expected="${REPO_ROOT}/completions/ferment.bash" ;;
      zsh)  expected="${REPO_ROOT}/completions/_ferment"     ;;
      fish) expected="${REPO_ROOT}/completions/ferment.fish" ;;
    esac
    generated="$(${FERMENT} completion $shell)"
    diff <(printf '%s\n' "$generated") "$expected"
  done
}
