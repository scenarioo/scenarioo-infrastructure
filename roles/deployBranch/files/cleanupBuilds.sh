#!/bin/bash
#
# Remove all builds that are not present in branchConfig.json
#

BRANCH=$1
SCENARIOO_FOLDER=$2
BRANCH_FOLDER="$SCENARIOO_FOLDER/$BRANCH"
BRANCH_CONFIG="$BRANCH_FOLDER/branchConfig.json"
BUILDS_FOLDER="$BRANCH_FOLDER/scenarioo-$BRANCH"

if [[ $BRANCH == "" || $SCENARIOO_FOLDER == "" ]]; then
    echo "Missing arguments: <branch> <scenariooFolder>"
    exit 1;
fi

echo "BUILDS_FOLDER: $BUILDS_FOLDER"

# Iterate over builds
for DIR in $BUILDS_FOLDER/*/; do
    DIR=${DIR%*/}           # Remove slash at end of DIR name
    BUILD=${DIR##*/build-}  # Remove /build- from dir name to get build number
    BUILD_CONFIG=`jq ".docuArtifacts[] | select(.build==\"$BUILD\")" $BRANCH_CONFIG`
    if [[ $BUILD_CONFIG == "" ]]; then
        # Build config not found => remove build data
        echo "Removing build #$BUILD"
        rm $BUILDS_FOLDER/build-$BUILD
    fi
done
