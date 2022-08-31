#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build
fi

helm template \
    --namespace nf-discovery \
    nf-discovery . \
    | kubectl -n nf-discovery apply -f -

