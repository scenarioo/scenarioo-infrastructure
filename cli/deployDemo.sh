#!/bin/bash
# DESCRIPTION: <branch> <buildNumber> <triggeredBy> <prUrl> Deploys or updates a demo

# INPUT DATA
BRANCH=$1
BUILD_NUMBER=$2
TRIGGERED_BY=$3
PR_URL=$4

# OTHER VARS
BUILD_URL="https://circleci.com/gh/scenarioo/scenarioo/$2"
ENCODED_BRANCH=`echo $BRANCH | tr / - | sed 's/#//g'`
TIMESTAMP=`date +%s`
CONFIG_FILE="demos/$ENCODED_BRANCH.json"

# FETCH ARTIFACTS
function abort_on_curl_failure() {
    if [[ $1 -gt 0 ]]; then
        echo "CURL failed fetching: $2"
        exit $1
    fi
}
CIRCLE_TOKEN=dea62ff49e21fe99d62efec247ae394ff1d6944a
ARTIFACT_URL="https://circleci.com/api/v1.1/project/github/scenarioo/scenarioo/${BUILD_NUMBER}/artifacts?circle-token=${CIRCLE_TOKEN}"

echo "Getting list of artifacts ..."
ARTIFACTS=`curl -s $ARTIFACT_URL`
abort_on_curl_failure $? $ARTIFACT_URL
echo "Getting WAR"
WAR_ARTIFACT=`echo $ARTIFACTS | jq -r '.[] | select(.path=="scenarioo.war") | .url'`
WAR_ARTIFACT_SHA256_URL=`echo $ARTIFACTS | jq -r '.[] | select(.path=="scenarioo.war.sha256") | .url'`
WAR_ARTIFACT_SHA256=`curl -s $WAR_ARTIFACT_SHA256_URL`
abort_on_curl_failure $? $WAR_ARTIFACT_SHA256_URL
Echo "Getting E2E docu"
DOCU_ARTIFACT=`echo $ARTIFACTS | jq -r '.[] | select(.path=="e2eScenariooDocu.zip") | .url'`
DOCU_ARTIFACT_SHA256_URL=`echo $ARTIFACTS | jq -r '.[] | select(.path=="e2eScenariooDocu.zip.sha256") | .url'`
DOCU_ARTIFACT_SHA256=`curl -s $DOCU_ARTIFACT_SHA256_URL`
abort_on_curl_failure $? $DOCU_ARTIFACT_SHA256_URL



DOCU_ARTIFACT_ITEM=$(cat << EOM
{
    "url": "$DOCU_ARTIFACT",
    "sha256": "$DOCU_ARTIFACT_SHA256",
    "build": "$BUILD_NUMBER"
}
EOM
)

# Update docu artifact list if needed with new docu
DOCU_ARTIFACT_LIST="[$DOCU_ARTIFACT_ITEM]"
# Demo already exists
if [[ -f $CONFIG_FILE ]]; then
    # Check if current build is not in list
    EXISTING_ITEMS=`jq ".docuArtifacts" $CONFIG_FILE`
    if [[ -z `jq -r ".docuArtifacts[] | select(.sha256==\"$DOCU_ARTIFACT_SHA256\") | .url" $CONFIG_FILE` ]]; then
        # Prepend new docu in DOCU_ARTIFACT_LIST
        DOCU_ARTIFACT_LIST=`jq ".docuArtifacts |= $DOCU_ARTIFACT_LIST + . | .docuArtifacts | sort_by(.build)" $CONFIG_FILE`
    else
        DOCU_ARTIFACT_LIST="$EXISTING_ITEMS"
    fi
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
    "docuArtifacts":    $DOCU_ARTIFACT_LIST
}
EOF
)

# Print it once for feedback & debugging
echo $JSON | jq '.'

# If last command failed the JSON was invalid
if [[ $? -gt 0 ]]; then
    echo $JSON
    echo "JSON invalid, will not write file"
else
    # JSON valid => write config file
    echo $JSON | jq '.' > $CONFIG_FILE
fi

./cli/updateOverview.sh
