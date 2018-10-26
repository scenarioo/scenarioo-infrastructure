#!/bin/bash
# DESCRIPTION: Undeploys a demo branch

# INPUT DATA
BRANCH=$1

ENCODED_BRANCH=`echo $BRANCH | tr / - | sed 's/#//g'`
CONFIG_FILE="demos/$ENCODED_BRANCH.json"

rm $ENCODED_BRANCH

./updateOverview.sh





