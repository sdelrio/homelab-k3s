#!/bin/sh

helm template \
    --include-crds \
    --namespace vault-server \
    vault-server . \
    | kubectl -n vault-server apply -f -

#echo
#echo "# Check Vault:"
#echo
#kubectl -n vault-operator wait --timeout=60s --for condition=Established \
#  customresourcedefinition.apiextensions.k8s.io/vaults.vault.banzaicloud.com

