#!/usr/bin/env bats

load environment

setup() {
    setup_environment
}

@test "deployDemo - it should generate a correct <demo>.config" {
    result="$(./infra.sh deployDemo testBranch 227 testUser http://foobar/PR 700 | grep -v timestamp)"
    expected="$(cat tests/expected/deployDemo.out | grep -v timestamp)"
    # Check output
    diff <(echo "$result") <(echo "$expected")

    # Check JSON
    result="$(cat $DEMO_DIR/testBranch.json | grep -v timestamp)"
    expected="$(cat tests/expected/deployDemo_testBranch.json | grep -v timestamp)"
    diff <(echo "$result") <(echo "$expected")
}

@test "deployDemo - it should rotate builds by build number" {
    ./infra.sh deployDemo testBranch 227 testUser http://foobar/PR 700
    ./infra.sh deployDemo testBranch 230 testUser http://foobar/PR 700
    ./infra.sh deployDemo testBranch 232 testUser http://foobar/PR 700
    result="$(cat $OVERVIEW_TARGET_DIR/demos.json | grep -v timestamp)"
    expected="$(cat tests/expected/deployDemo_rotateBuild_demos.json | grep -v timestamp)"

    # Check aggregated JSON
    diff <(echo "$result") <(echo "$expected")
}


@test "deployDemo - it should rotate demos by timestamp" {
    ./infra.sh deployDemo demo1 227 testUser http://foobar/PR 700
    sleep 1 # With cached curl calls we might return here in under a second and end up with the same timestamp => sleep
    ./infra.sh deployDemo demo2 230 testUser http://foobar/PR 700
    sleep 1
    ./infra.sh deployDemo demo3 232 testUser http://foobar/PR 700
    result="$(cat $OVERVIEW_TARGET_DIR/demos.json | grep -v timestamp)"
    expected="$(cat tests/expected/deployDemo_rotateDemos_demos.json | grep -v timestamp)"
    cp $OVERVIEW_TARGET_DIR/demos.json tests
    # Check aggregated JSON
    diff <(echo "$result") <(echo "$expected")
}


teardown() {
    restore_environment
}