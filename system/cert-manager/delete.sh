#!/bin/sh

NS=`basename "$PWD"`
DEPLOY=${NS}

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build
fi

ho helm template \
    --namespace ${NS} \
    ${DEPLOY} . \
    | kubectl -n ${NS} delete --wait=true -f -

