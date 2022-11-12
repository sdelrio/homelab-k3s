#!/bin/bash

NS=${NS:-`basename "$PWD"`}
DEPLOY=${DEPLOY:-`basename "$PWD"`}
HELM_EXTRA=${HELM_EXTRA:-}
DEBUG=${DEBUG:-false}

echo namespace: ${NS}
echo deployment: ${DEPLOY}

if [ ! -d charts ]; then
   echo "Building depencency..."
   ${DBG_COMMAND} helm dependency build
fi

if [ -f values-extra.yaml ]; then
    HELM_EXTRA="-f values-extra.yaml"
fi

if [ "$DEBUG" = "true" ]; then
    echo helm template \
        --namespace ${NS} \
        ${HELM_EXTRA} \
        ${DEPLOY} .
else
    helm template \
        --namespace ${NS} \
        ${HELM_EXTRA} \
        ${DEPLOY} . \
        | kubectl -n ${NS} delete -f -
fi
