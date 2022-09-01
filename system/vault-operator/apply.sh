#!/bin/sh


if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --include-crds \
    --namespace vault-operator \
    vault-operator . \
    | kubectl -n vault-operator apply -f -

echo
echo "# Check CRDs:"
echo
kubectl -n vault-operator wait --timeout=60s --for condition=Established \
  customresourcedefinition.apiextensions.k8s.io/vaults.vault.banzaicloud.com

