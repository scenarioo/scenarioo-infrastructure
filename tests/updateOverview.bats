#!/usr/bin/env bats

load environment

setup() {
    setup_environment
    cp tests/expected/updateOverview_demo1.json $DEMO_DIR
    cp tests/expected/updateOverview_demo2.json $DEMO_DIR
}

@test "updateOverview - it should concat demo configs" {
    ./infra.sh updateOverview
    result="$(cat $OVERVIEW_TARGET_DIR/demos.json)"
    expected="$(cat tests/expected/updateOverview_demos.json)"

    diff <(echo "$result") <(echo "$expected")
}

@test "updateOverview - running it twice should not change the output" {
    ./infra.sh updateOverview
    ./infra.sh updateOverview
    result="$(cat $OVERVIEW_TARGET_DIR/demos.json)"
    expected="$(cat tests/expected/updateOverview_demos.json)"

    diff <(echo "$result") <(echo "$expected")
}

teardown() {
    restore_environment
}