#!/bin/bash
# Avoid path issues by entering this directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd ${DIR} >/dev/null

COMMAND=$1
shift  > /dev/null # Shift all args by one => $2 becomes $1
if [[ -x cli/$COMMAND.sh ]]; then
    # Execute command with remaining args
    ./cli/$COMMAND.sh "$@"
else
    echo "Command \"$COMMAND\" not found";
    echo "Available commands:"
    ls -F1 ./cli | grep '*$' | sed -e 's/\..*$//' | ./cli/util/describeCommand.sh
fi

popd >/dev/null