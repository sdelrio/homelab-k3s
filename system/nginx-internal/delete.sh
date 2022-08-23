#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace kube-system \
    nginx-internal . \
    | kubectl -n kube-system delete -f -

