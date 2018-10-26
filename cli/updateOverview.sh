#!/bin/bash
# DESCRIPTION: Generates a new overviewpage/demos.json

echo "Updating list of demos: overviewpage/demos.json"
jq -s '.' demos/*.json > overviewpage/demos.json
