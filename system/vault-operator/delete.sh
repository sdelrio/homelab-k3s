#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace vault-operator \
    vault-operator . \
    | kubectl -n vault-operator delete -f -

