#!/bin/bash
# DESCRIPTION: <branch> <buildNumber> <triggeredBy> <prUrl> Deploys or updates a demo

# bash 'strict mode': http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

CONFIG_FILE=${CONFIG_FILE:-config.json}
DEMO_DIR=`jq -r '.demoConfigFolder' $CONFIG_FILE`

# INPUT DATA
BRANCH=$1
BUILD_NUMBER=$2
TRIGGERED_BY=$3
PR_URL=$4

# OTHER VARS
BUILD_URL="https://circleci.com/gh/scenarioo/scenarioo/$2"
ENCODED_BRANCH=`echo $BRANCH | sed 's/\//\-/g' | sed 's/\#/\-/g'`
TIMESTAMP=`date +%s`
BRANCH_CONFIG_FILE="$DEMO_DIR/$ENCODED_BRANCH.json"

# FETCH ARTIFACTS
function abort_on_curl_failure() {
    if [[ $1 -gt 0 ]]; then
        echo "CURL failed fetching: $2"
        exit $1
    fi
}
# Warn if CIRCLE_TOKEN is empty
CIRCLE_TOKEN=${CIRCLE_TOKEN:-}
if [[ -z $CIRCLE_TOKEN ]]; then
    echo "WARNING: CIRCLE_TOKEN is not set. Without it we can't fetch artifacts from builds!"
fi
ARTIFACT_URL="https://circleci.com/api/v1.1/project/github/scenarioo/scenarioo/${BUILD_NUMBER}/artifacts?circle-token=${CIRCLE_TOKEN}"

echo "Getting list of artifacts ..."
ARTIFACTS=`curl -s $ARTIFACT_URL`
abort_on_curl_failure $? $ARTIFACT_URL

echo "Getting WAR"
WAR_ARTIFACT=`echo $ARTIFACTS | jq -r '.[] | select(.path=="scenarioo.war") | .url'`
WAR_ARTIFACT_SHA256_URL=`echo $ARTIFACTS | jq -r '.[] | select(.path=="scenarioo.war.sha256") | .url'`
if [[ $WAR_ARTIFACT_SHA256_URL == "" ]]; then
    echo "No WAR or WAR SHA256 found in list of artifacts"
fi
WAR_ARTIFACT_SHA256=`curl -s $WAR_ARTIFACT_SHA256_URL`
abort_on_curl_failure $? $WAR_ARTIFACT_SHA256_URL

echo "Getting E2E docu"
E2E_DOCU_ARTIFACT=`echo $ARTIFACTS | jq -r '.[] | select(.path=="e2eScenariooDocu.zip") | .url'`
E2E_DOCU_ARTIFACT_SHA256_URL=`echo $ARTIFACTS | jq -r '.[] | select(.path=="e2eScenariooDocu.zip.sha256") | .url'`
if [[ $E2E_DOCU_ARTIFACT_SHA256_URL == "" ]]; then
    echo "No docu or docu SHA256 found in list of artifacts"
fi
E2E_DOCU_ARTIFACT_SHA256=`curl -s $E2E_DOCU_ARTIFACT_SHA256_URL`
abort_on_curl_failure $? $E2E_DOCU_ARTIFACT_SHA256_URL

echo "Getting example docu"
EXAMPLE_DOCU_ARTIFACT=`echo $ARTIFACTS | jq -r '.[] | select(.path=="exampleScenariooDocu.zip") | .url'`
EXAMPLE_DOCU_ARTIFACT_SHA256_URL=`echo $ARTIFACTS | jq -r '.[] | select(.path=="exampleScenariooDocu.zip.sha256") | .url'`
if [[ $EXAMPLE_DOCU_ARTIFACT_SHA256_URL == "" ]]; then
    echo "No docu or docu SHA256 found in list of artifacts"
fi
EXAMPLE_DOCU_ARTIFACT_SHA256=`curl -s $EXAMPLE_DOCU_ARTIFACT_SHA256_URL`
abort_on_curl_failure $? $EXAMPLE_DOCU_ARTIFACT_SHA256_URL



DOCU_ARTIFACT_ITEM=$(cat << EOM
{
    "url": "$E2E_DOCU_ARTIFACT",
    "sha256": "$E2E_DOCU_ARTIFACT_SHA256",
    "build": "$BUILD_NUMBER"
}
EOM
)

# Update docu artifact list if needed with new docu
DOCU_ARTIFACT_LIST="[$DOCU_ARTIFACT_ITEM]"
# Demo already exists
if [[ -f $BRANCH_CONFIG_FILE ]]; then
    # Check if current build is not in list
    EXISTING_ITEMS=`jq ".docuArtifacts" $BRANCH_CONFIG_FILE`
    if [[ -z `jq -r ".docuArtifacts[] | select(.sha256==\"$E2E_DOCU_ARTIFACT_SHA256\") | .url" $BRANCH_CONFIG_FILE` ]]; then
        # Prepend new docu in DOCU_ARTIFACT_LIST
        DOCU_ARTIFACT_LIST=`jq ".docuArtifacts |= $DOCU_ARTIFACT_LIST + . | .docuArtifacts | sort_by(.build)" $BRANCH_CONFIG_FILE`
    else
        DOCU_ARTIFACT_LIST="$EXISTING_ITEMS"
    fi
fi

# Limit the docu artifact list to maxBuildsPerDemo
MAX_BUILDS_PER_DEMO=`jq '.maxBuildsPerDemo' $CONFIG_FILE`
ARTIFACTS_TO_BE_REMOVED=`echo $DOCU_ARTIFACT_LIST | jq -r "[. | sort_by(.build) | .[:-$MAX_BUILDS_PER_DEMO] | .[].build] | @csv"`

if [[ $ARTIFACTS_TO_BE_REMOVED != "" ]]; then
    echo "Removing builds: $ARTIFACTS_TO_BE_REMOVED"
    DOCU_ARTIFACT_LIST=`echo $DOCU_ARTIFACT_LIST | jq ". | sort_by(.build) | .[-$MAX_BUILDS_PER_DEMO:]"`
fi

# Final JSON
JSON=$(cat << EOF
{
    "branchName":       "$BRANCH",
    "encodedBranchName":"$ENCODED_BRANCH",
    "timestamp":        "$TIMESTAMP",
    "buildNumber":      "$BUILD_NUMBER",
    "triggeredBy":      "$TRIGGERED_BY",
    "pullRequestUrl":   "$PR_URL",
    "buildUrl":         "$BUILD_URL",
    "warArtifact":      "$WAR_ARTIFACT",
    "warArtifactSha256":"$WAR_ARTIFACT_SHA256",
    "exampleDocuArtifact":       "$EXAMPLE_DOCU_ARTIFACT",
    "exampleDocuArtifactSha256": "$EXAMPLE_DOCU_ARTIFACT_SHA256",
    "docuArtifacts":    $DOCU_ARTIFACT_LIST
}
EOF
)

# Print it once for feedback & debugging
echo "New branch config:"
echo $JSON | jq '.'

# If last command failed the JSON was invalid
if [[ $? -gt 0 ]]; then
    echo $JSON
    echo "JSON invalid, will not write file"
else
    # JSON valid => write config file
    echo "Writing config file $BRANCH_CONFIG_FILE..."
    echo $JSON | jq '.' > $BRANCH_CONFIG_FILE
fi

echo "Demo $ENCODED_BRANCH added. Starting cleanup ..."
echo

./cli/cleanupDemos.sh
