#!/bin/sh

NS=`basename "$PWD"`
DEPLOY=${NS}

if [ ! -f Chart.lock ]; then
   echo "Building helm depencency..."
   helm dependency update
fi

# requires namespace to be already created
helm template \
    --namespace ${NS} \
    ${DEPLOY} . \
    | kubectl -n ${NS} apply -f -

