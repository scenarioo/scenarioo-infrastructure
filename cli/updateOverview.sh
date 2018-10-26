#!/bin/bash
# DESCRIPTION: Generates a new overviewpage/demos.json

echo "Generate new list of demos: page/demos.json"
jq -s '.' demos/*.json > overviewpage/demos.json

echo "DONE"





