#!/bin/bash
# DESCRIPTION: <branch> Undeploys a demo branch

# INPUT DATA
BRANCH=$1

ENCODED_BRANCH=`echo $BRANCH | tr / _ | sed 's/#//g'`
CONFIG_FILE="demos/$ENCODED_BRANCH.json"

rm $CONFIG_FILE
echo "Removed branch: $BRANCH"

./cli/updateOverview.sh
