#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build
fi

helm template \
    --namespace openebs-localpv \
    openebs-localpv . \
    | kubectl -n openebs-localpv delete  --wait=true -f -

