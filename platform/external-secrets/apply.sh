#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build
fi

helm template \
    --include-crds \
    --namespace external-secrets \
    external-secrets . \
    | kubectl -n external-secrets apply -f -

echo
echo "# Check Vault:"
echo
kubectl -n vault-operator wait --timeout=60s --for condition=Established \
    customresourcedefinition.apiextensions.k8s.io/clusterexternalsecrets.external-secrets.io \
    customresourcedefinition.apiextensions.k8s.io/clustersecretstores.external-secrets.io \
    customresourcedefinition.apiextensions.k8s.io/externalsecrets.external-secrets.io \
    customresourcedefinition.apiextensions.k8s.io/secretstores.external-secrets.io 

