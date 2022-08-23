#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build
fi

helm template \
    --namespace external-dns \
    external-dns . \
    | kubectl -n external-dns apply -f -

