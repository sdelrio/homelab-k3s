#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace kube-system \
    nginx-external . \
    | kubectl -n kube-system delete -f -

