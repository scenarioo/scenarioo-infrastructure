#!/bin/bash
# DESCRIPTION: Enforces maxConcurrentDemos

CONFIG_FILE=${CONFIG_FILE:-config.json}
DEMO_DIR=`jq -r '.demoConfigFolder' $CONFIG_FILE`

OVERVIEW_TARGET_DIR=${OVERVIEW_TARGET_DIR:-overviewpage}      # Will be overriden during testing

./cli/updateOverview.sh

MAX_CONCURRENT_DEMOS=`jq '.maxConcurrentDemos' $CONFIG_FILE`
DEMO_COUNT=`jq '. | length' $OVERVIEW_TARGET_DIR/demos.json`
PERSISTENT_BRANCHES=`jq -r '.persistentBranches[]' $CONFIG_FILE`
PERSISTENT_BRANCHES_COUNT=`jq -r '.persistentBranches | length' $CONFIG_FILE`
echo "Persistent branches: `jq -r '.persistentBranches | @csv' $CONFIG_FILE`"

if (( $MAX_CONCURRENT_DEMOS < $PERSISTENT_BRANCHES_COUNT )); then
    echo "More persistent branches than allowed by maxConcurrentDemos";
    exit 1;
fi

# Filter out persistent branches
NON_PERSISTENT_DEMOS=`jq '. | sort_by(-(.timestamp | tonumber))' $OVERVIEW_TARGET_DIR/demos.json`
for PERSISTENT_BRANCH in $PERSISTENT_BRANCHES; do
    NON_PERSISTENT_DEMOS=`echo $NON_PERSISTENT_DEMOS | jq "[ .[] | select(.encodedBranchName!=\"$PERSISTENT_BRANCH\") ]"`
done

NON_PERSISTENT_DEMOS_COUNT=`echo $NON_PERSISTENT_DEMOS | jq '. | length'`
MAX_NON_PERSISTENT_DEMOS=`expr $MAX_CONCURRENT_DEMOS - $DEMO_COUNT + $NON_PERSISTENT_DEMOS_COUNT`
DEMOS_TO_REMOVE=`expr $NON_PERSISTENT_DEMOS_COUNT - $MAX_NON_PERSISTENT_DEMOS`

if [[ $DEMOS_TO_REMOVE -gt 0 ]]; then
    TO_BE_DELETED_DEMOS=`echo $NON_PERSISTENT_DEMOS | jq -r ".[-$DEMOS_TO_REMOVE:] | .[].encodedBranchName"`
else
    DEMOS_TO_REMOVE=0
fi


echo "Max demos:       $MAX_CONCURRENT_DEMOS"
echo "Total demos:     $DEMO_COUNT"
echo "Demos to remove: $DEMOS_TO_REMOVE"
echo "=================================="

# Remove branches
for DEMO in $TO_BE_DELETED_DEMOS; do
    echo "Removing $DEMO"
    ./cli/undeployDemo.sh $DEMO
done
echo "=================================="

./cli/updateOverview.sh
