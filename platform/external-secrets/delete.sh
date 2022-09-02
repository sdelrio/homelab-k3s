#!/bin/sh

helm template \
    --namespace external-secrets \
    external-secrets . \
    | kubectl -n external-secrets delete -f -

