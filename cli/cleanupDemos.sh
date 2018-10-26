#!/bin/bash
# DESCRIPTION: Enforces maxConcurrentDemos and maxBuildsPerDemo

./cli/updateOverview.sh

MAX_CONCURRENT_DEMOS=`jq '.maxConcurrentDemos' config.json`
DEMO_COUNT=`jq '. | length' overviewpage/demos.json`
PERSISTENT_BRANCHES=`jq -r '.persistentBranches[]' config.json`
PERSISTENT_BRANCHES_COUNT=`jq -r '.persistentBranches | length' config.json`
echo "Persistent branches: `jq -r '.persistentBranches | @csv' config.json`"

if (( $MAX_CONCURRENT_DEMOS < $PERSISTENT_BRANCHES_COUNT )); then
    echo "More persistent branches than allowed by maxConcurrentDemos";
    exit 1;
fi

# Filter out persistent branches
NON_PERSISTENT_DEMOS=`jq '. | sort_by(.timestamp)' overviewpage/demos.json`
for PERSISTENT_BRANCH in $PERSISTENT_BRANCHES; do
    NON_PERSISTENT_DEMOS=`echo $NON_PERSISTENT_DEMOS | jq "[ .[] | select(.encodedBranchName!=\"$PERSISTENT_BRANCH\") ]"`
done

MAX_NON_PERSISTENT_DEMOS=`expr $MAX_CONCURRENT_DEMOS - $PERSISTENT_BRANCHES_COUNT`
NON_PERSISTENT_DEMOS_COUNT=`echo $NON_PERSISTENT_DEMOS | jq '. | length'`
DEMOS_TO_REMOVE=`expr $NON_PERSISTENT_DEMOS_COUNT - $MAX_NON_PERSISTENT_DEMOS`

echo "Max demos:       $MAX_CONCURRENT_DEMOS"
echo "Total demos:     $DEMO_COUNT"
echo "Demos to remove: $DEMOS_TO_REMOVE"
echo "=================================="

# Remove branches
TO_BE_DELETED_DEMOS=`echo $NON_PERSISTENT_DEMOS | jq -r ".[-$DEMOS_TO_REMOVE:] | .[].encodedBranchName"`

for DEMO in $TO_BE_DELETED_DEMOS; do
    echo "Removing $DEMO"
    rm demos/$DEMO.json
done
echo "=================================="

./cli/updateOverview.sh
