#!/bin/sh

NS=`basename "$PWD"`
DEPLOY=${NS}

if [ ! -f Chart.lock ]; then
   echo "Building helm depencency..."
   helm dependency update
fi

# requires namespace to be already created
helm template \
    --include-crds \
    --namespace ${NS} \
    ${DEPLOY} . \
    | kubectl -n ${NS} apply -f -


echo
echo "# Check CRDs:"
echo
kubectl -n vault-operator wait --timeout=60s --for condition=Established \
    customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io \
    customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io \
    customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io \
    customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io \
    customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io \
    customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io

