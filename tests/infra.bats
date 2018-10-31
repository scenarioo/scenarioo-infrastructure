#!/usr/bin/env bats

load environment

setup() {
    setup_environment
}

@test "infra.sh - it should print available commands" {
  result="$(./infra.sh)"
  expected="$(cat tests/expected/infra_showCommands.out)"

  diff <(echo "$result") <(echo "$expected")
}

teardown() {
    restore_environment
}