#!/bin/sh

NS=kube-system
DEPLOY=`basename "$PWD"`

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build
fi

# requires namespace to be created

helm template \
    --namespace ${NS} \
    ${DEPLOY} . \
    | kubectl -n ${NS} apply -f -

