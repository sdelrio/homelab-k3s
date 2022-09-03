#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace intel-gpu-plugin \
    intel-gpu-plugin . \
    | kubectl -n intel-gpu-plugin delete -f -

