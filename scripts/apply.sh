#!/bin/bash

NS=${NS:-`basename "$PWD"`}
DEPLOY=${DEPLOY:-`basename "$PWD"`}
CRD_FILE=${CRD_FILE:-crd.txt}
WAIT_FILE=${WAIT_FILE:-wait.txt}
TIMEOUT=60s
DEBUG=${DEBUG:-false}
HELM_EXTRA=${HELM_EXTRA:-}

echo namespace: ${NS}
echo deployment: ${DEPLOY}

if [ "${DEBUG}" == "true" ]; then
    kubectl get ns ${NS} || echo namespace ${NS} not found
else
    kubectl get ns ${NS} || kubectl create ns ${NS}
fi

if [ -f kustomization.yaml ]; then

    if [ "${DEBUG}" == "true" ]; then
        kustomize build --enable-helm
    else
        kustomize build --enable-helm | kubectl apply -f -
    fi

elif [ -f Chart.yaml ]; then

    if [ ! -d charts ]; then
        echo "Building depencency..."
        helm dependency build 
    fi

    if [ -f values-extra.yaml ]; then
        HELM_EXTRA="-f values-extra.yaml"
    fi

    if [ "${DEBUG}" == "true" ]; then
        helm template \
        --include-crds \
        ${HELM_EXTRA} \
        --namespace ${NS} ${DEPLOY} .
    else
        helm template \
        --include-crds \
        ${HELM_EXTRA} \
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
        echo kubectl -n ${NS} wait --timeout=${TIMEOUT} --for condition=Established \
        ${crd}
    else
        kubectl -n ${NS} wait --timeout=${TIMEOUT} --for condition=Established \
        ${crd}
    fi
fi


if [ -f ${WAIT_FILE} ]; then
    pattern="^timeout=[0-9]+(m|s)"
    while IFS= read -r line
    do
      # take action on $line #
      if [[ $line =~ $pattern ]]; then
        arrIN=(${line//=/ })
        TIMEOUT=${arrIN[1]}
      else
        wait="$wait $line"
      fi
    done <<< $(cat ${WAIT_FILE})

    if [ "${DEBUG}" == "true" ]; then
        echo kubectl -n ${NS} wait --timeout=${TIMEOUT} --for condition=Established \
        ${wait} --all
    else
        kubectl -n ${NS} wait --timeout=${TIMEOUT} --for condition=Established \
        ${wait} --all
    fi
fi

