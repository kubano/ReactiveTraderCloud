#! /bin/bash

$BRANCH=${CIRCLE_BRANCH: "develop"}

COMPARE_FROM=$(git rev-parse $BRANCH)
if [[ $(echo $BRANCH | grep -E "(master|develop)") != "" ]]; then
    COMPARE_FROM="@"
fi;

export BUILD_LIST=()
export LOAD_LIST=()
export RUN_LIST=()
export PULL_LIST=()
export TOUCHED_FILES=$(git diff --name-only --diff-filter=ADMR $COMPARE_POINT~..@)

[[ $(echo $TOUCHED_FILES | grep "^src/server") != "" ]] && \
    export SERVER_TOUCHED=1 || export SERVER_TOUCHED=0

[[ $(echo $TOUCHED_FILES | grep -E "(^src/client|/web)") != "" ]] && \
    export CLIENT_TOUCHED=1 || export CLIENT_TOUCHED=0

if [[ $(echo $TOUCHED_FILES | grep "^src/server") != "" ]]; then
    LOAD_LIST+=("dotnet" "crossbar" "eventstore")
    BUILD_LIST+=("servers" "broker" "populatedEventstore")
    RUN_LIST+=("eventstore" "broker" "referencedataread" "pricing" "tradeexecution" "blotter" "analytics")
else
    PULL_LIST+=("servers" "broker" "populatedEventstore")
fi

if [[ $(echo $TOUCHED_FILES | grep -E "(^src/client|/web)") != "" ]]; then
    BUILD_LIST+=("web")
    RUN_LIST+=("web")
fi