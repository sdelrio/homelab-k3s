#!/bin/bash

NS=${NS:-`basename "$PWD"`}
DEPLOY=${DEPLOY:-$NS}

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace ${NS} \
    ${DEPLOY} . \
    | kubectl -n ${NS} delete -f -

