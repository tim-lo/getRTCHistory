#!/bin/bash
REPO="$1";
PROJECT="$2";
STREAM_UUID="$3";
STREAM_NAME="";
USER="$4";
PASS="$5";

# Get the list of components
echo "Getting list of components for $STREAM_UUID...";
scm --show-alias n --show-uuid n list components -r "$REPO" --projectarea "$PROJECT" -u "$USER" -P "$PASS" > .components;
sed -i 's/^ "//g' .components;
sed -i 's/"$//g' .components;
echo -e "\e[1AGetting list of components for $STREAM_UUID...Done";

# Get the list of changesets for each of the components (maximum=1M to make scm returns all changesets)
OLDIFS="$IFS";
IFS=$'\n';
COMPONENT_NAMES=();
while read line; do
    COMPONENT_NAMES=("${COMPONENT_NAMES[@]}" "$line");
done < .components
IFS="$OLDIFS";

for COMPONENT_NAME in ${COMPONENT_NAMES[@]}; do
    COMPONENT_NAME="Drupal $COMPONENT_NAME";
    echo "Getting changesets for $COMPONENT_NAME...";
    scm --show-uuid y list changesets -r "$REPO" -w "$STREAM_UUID" -C "$COMPONENT_NAME" -u "$USER" -P "$PASS" -m 1000000 > "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt";
    echo -e "\e[1AGetting changesets for $COMPONENT_NAME...Done";
    mkdir ./History;
    echo "Getting changeset urls for $COMPONENT_NAME...";
    sed -i 's/^Change sets:$//g' "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt";
    sed -i '/^$/d' "./History_${COMPONENT_NAME}_${STREAM_UUID}.txt";
    sed -i 's/^  ([0-9-]*://g' "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt";
    sed -i 's/).*$//g' "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt";
    sed -i "s/^/$REPO\/resource\/itemOid\/com.example.team.scm.ChangeSet\//g" "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt"; # Change regex as appropriate (see Eclipse/RTC Client history url for reference)
    sed -i "s/$/?Workspace=$STREAM_UUID/g" "./History/History_${COMPONENT_NAME}_${STREAM_UUID}.txt";
    echo -e "\e[1AGetting changeset urls for $COMPONENT_NAME...Done";
done
