#!/bin/bash
REPO=$1
PROJECT=$2
STREAM_NAME=$3
USER=$4
PASS=$5

# check arguments
if [ ! $# -eq 5 ]; then
    echo "Usage:"
    echo "  ./getRTCHistory.sh [jazzRepository] [ProjectArea] [StreamName] [User] [Password]"
    exit 1
fi

# preparation
echo "Preparation"
if [ -d ./.tmp ]; then
    rm -rf ./.tmp;
    echo "> Removed old .tmp directory"
fi
if [ ! -d ./.tmp ]; then
    mkdir ./.tmp;
    echo "> Created new empty .tmp directory"
fi
if [ -d ./History ]; then
    rm -rf ./History;
    echo "> Removed output directory"
fi
if [ ! -d ./History ]; then
    mkdir ./History;
    echo "> Created new empty output (History) directory"
fi

# get stream UUID
echo "> Get UUID of Stream: $STREAM_NAME"
STREAM_UUID=`scm list streams -r "$REPO" --projectarea "$PROJECT" -u "$USER" -P "$PASS" | grep "$STREAM_NAME" | cut -f1 -d ')' | cut -f2 -d '('`
echo "> > Got Stream's UUID: $STREAM_UUID"
echo "Preparation...Done"

# Get the list of components from JAZZ
echo
echo "Get list of components"
echo "> List of components for: ($STREAM_UUID) $STREAM_NAME...";
lscm ls comp -r "$REPO" -u "$USER" -P "$PASS" "$STREAM_NAME" > ./.tmp/components_jazz
grep -rnw "./.tmp/components_jazz" -e "Component" | cut -f2 -d'"' > ./.tmp/components
echo "Get list of components...Done"

# Read components from .components
echo
echo "Reading components names...";
COMPONENT_NAMES=""
while read line; do
    COMPONENT_NAMES=("${COMPONENT_NAMES[@]}" "$line")
done < ./.tmp/components
echo "Reading components names...Done"

OLDIFS=$IFS
IFS=$'\n'       # make newlines the only separator
# get changesets for component
echo
echo "Getting changesets...";
for COMPONENT_NAME in ${COMPONENT_NAMES[@]}; do  
    echo "> Getting changesets for component: '$COMPONENT_NAME' ..."
    scm --show-uuid y list changesets -r "$REPO" -w "$STREAM_UUID" -C "$COMPONENT_NAME" -u "$USER" -P "$PASS" -m 1000000 > "./.tmp/History_${COMPONENT_NAME}_${STREAM_NAME}.changesets"
    #cp "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.changesets" "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt"
    echo "> Getting changesets for component: '$COMPONENT_NAME' ...Done"
done
echo "Getting changesets...Done"

# get changesets UUID
echo
echo "Getting UUIDs from changesets"
for COMPONENT_NAME in ${COMPONENT_NAMES[@]}; do
    echo "> Getting changeset urls for $COMPONENT_NAME..."
    IN_FILE="./.tmp/History_${COMPONENT_NAME}_${STREAM_NAME}.changesets"
    OUT_FILE="./History/History_${COMPONENT_NAME}_${STREAM_NAME}.txt"
    grep -rnw "$IN_FILE" -e "----" | cut -f2 -d'(' | cut -f2 -d':' | cut -f1 -d')' > $OUT_FILE
    echo "> Getting changeset urls for $COMPONENT_NAME...Done"
done
echo "Getting UUIDs from changesets...Done"
IFS=$OLDIFS
