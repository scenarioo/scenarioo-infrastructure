#!/bin/bash
# DESCRIPTION: Generates a new overviewpage/demos.json

CONFIG_FILE=${CONFIG_FILE:-config.json}
DEMO_DIR=`jq -r '.demoConfigFolder' $CONFIG_FILE`

OVERVIEW_TARGET_DIR=${OVERVIEW_TARGET_DIR:-overviewpage}      # Will be overriden during testing

echo "Updating list of demos: overviewpage/demos.json"
jq -s '.' $DEMO_DIR/*.json > $OVERVIEW_TARGET_DIR/demos.json
