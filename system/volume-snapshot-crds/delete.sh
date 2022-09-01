#!/bin/sh

kustomize build \
    | kubectl delete -f -

