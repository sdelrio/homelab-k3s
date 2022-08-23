#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace metallb-system \
    metallb-system . \
    | kubectl -n metallb-system delete -f -

