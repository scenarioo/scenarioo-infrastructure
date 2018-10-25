#!/bin/bash
# Reads command file and outputs text after DESCRIPTION_PREFIX as description for command
while read COMMAND    # Read from pipe
do
    DESCRIPTION_PREFIX="# DESCRIPTION: "
    DESCRIPTION=`grep "$DESCRIPTION_PREFIX" ./cli/$COMMAND.sh | sed -e "s/$DESCRIPTION_PREFIX//"`
    echo "  $COMMAND: $DESCRIPTION"
done