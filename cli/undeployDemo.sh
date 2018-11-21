#!/bin/bash
# DESCRIPTION: <branch> Undeploys a demo branch

# bash 'strict mode': http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

CONFIG_FILE=${CONFIG_FILE:-config.json}
DEMO_DIR=`jq -r '.demoConfigFolder' $CONFIG_FILE`

# INPUT DATA
BRANCH=$1

ENCODED_BRANCH=`echo $BRANCH | sed 's/\//\-/' | sed 's/\#/\-/'`
BRANCH_CONFIG_FILE="$DEMO_DIR/$ENCODED_BRANCH.json"

rm $BRANCH_CONFIG_FILE
echo "Removed branch: $BRANCH"

./cli/updateOverview.sh
