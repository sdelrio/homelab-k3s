#!/bin/bash

NS=${NS:-`basename "$PWD"`}
DEPLOY=${DEPLOY:-$NS}
CRD_FILE=${CRD_FILE:-crd.txt}

if [ ! -d charts ]; then
    echo "Building depencency..."
    helm dependency build 
fi

kubectl get ns reloader || kubectl create ns reloader

helm template \
    --include-crds \
    --namespace ${NS} \
    ${DEPLOY} . \
    | kubectl -n ${NS} apply -f -

if [ -f ${CRD_FILE} ]; then

    echo
    echo "# Check CRDs:"
    echo

    while IFS= read -r line
    do
      # take action on $line #
      crd="$crd $line"
    done <<< $(cat ${CRD_FILE})

    kubectl -n ${NS} wait --timeout=60s --for condition=Established \
        ${crd}
fi
