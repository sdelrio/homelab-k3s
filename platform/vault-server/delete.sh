#!/bin/sh

helm template \
    --namespace vault-server \
    vault-server . \
    | kubectl -n vault-server delete -f -

