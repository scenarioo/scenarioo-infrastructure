#!/bin/bash
# Reads command file and outputs text after DESCRIPTION_PREFIX as description for command
read COMMAND    # Read from pipe
DESCRIPTION_PREFIX="# DESCRIPTION: "
DESCRIPTION=`grep "$DESCRIPTION_PREFIX" ./cli/$COMMAND.sh | sed -e "s/$DESCRIPTION_PREFIX//"
`
echo "  $COMMAND: $DESCRIPTION"