#!/bin/bash

NS=${NS:-`basename "$PWD"`}
DEPLOY=${DEPLOY:-`basename "$PWD"`}
CRD_FILE=${CRD_FILE:-crd.txt}
DEBUG=${DEBUG:-true}

echo namespace: ${NS}
echo deployment: ${DEPLOY}

if [ "${DEBUG}" == "true" ]; then
    kubectl get ns ${NS} || echo namespace ${NS} not found
else
    kubectl get ns ${NS} || kubectl create ns ${NS}
fi

if [ -f kustomization.yaml ]; then
    if [ "${DEBUG}" == "true" ]; then
        kustomize build
    else
        kustomize build | kubectl apply -f -
    fi
fi

if [ -f Chart.yaml ]; then
    if [ ! -d charts ]; then
        echo "Building depencency..."
        helm dependency build 
    fi

    if [ "${DEBUG}" == "true" ]; then
        helm template \
        --include-crds \
        --namespace ${NS} ${DEPLOY} .
    else
        helm template \
        --include-crds \
        --namespace ${NS} \
        ${DEPLOY} . \
        | kubectl -n ${NS} apply -f -
    fi


fi

if [ -f ${CRD_FILE} ]; then

    echo
    echo "# Check CRDs:"
    echo

    while IFS= read -r line
    do
      # take action on $line #
      crd="$crd $line"
    done <<< $(cat ${CRD_FILE})

    if [ "${DEBUG}" == "true" ]; then
        echo kubectl -n ${NS} wait --timeout=60s --for condition=Established \
        ${crd}
    else
        kubectl -n ${NS} wait --timeout=60s --for condition=Established \
        ${crd}
    fi
fi
