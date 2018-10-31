#!/bin/bash
# DESCRIPTION: <branch> Undeploys a demo branch

CONFIG_FILE=${CONFIG_FILE:-config.json}
DEMO_DIR=`jq -r '.demoConfigFolder' $CONFIG_FILE`

# INPUT DATA
BRANCH=$1

ENCODED_BRANCH=`echo $BRANCH | tr / _ | sed 's/#//g'`
CONFIG_FILE="$DEMO_DIR/$ENCODED_BRANCH.json"

rm $CONFIG_FILE
echo "Removed branch: $BRANCH"

./cli/updateOverview.sh
