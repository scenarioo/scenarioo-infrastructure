#!/bin/bash

setup_environment() {
    export CONFIG_FILE=tests/config.test.json
    export DEMO_DIR=`jq -r '.demoConfigFolder' $CONFIG_FILE`
    export OVERVIEW_TARGET_DIR="tests/tmp"
    # Setup dir / clean up if needed
    mkdir -p $DEMO_DIR
    rm -f $DEMO_DIR/*
    rm -f $OVERVIEW_TARGET_DIR/demos.json
    ORIGINAL_PATH="$PATH"
    # Add mocked commands to path
    export PATH="tests/bin:$PATH"
}

restore_environment() {
    # Clean dirs
    rm -f $DEMO_DIR/*
    rm -f $OVERVIEW_TARGET_DIR/demos.json
    # Restore PATH
    export PATH="$ORIGINAL_PATH"
    # Clean up env vars
    unset ORIGINAL_PATH
    unset CONFIG_FILE
    unset DEMO_DIR
    unset OVERVIEW_TARGET_DIR
}