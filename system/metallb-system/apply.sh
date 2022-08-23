#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace metallb-system \
    metallb-system . \
    | kubectl -n metallb-system apply -f -

echo
echo "# Check CRDs:"
echo
kubectl -n metallb-system wait --timeout=60s --for condition=Established \
    customresourcedefinition.apiextensions.k8s.io/addresspools.metallb.io \
    customresourcedefinition.apiextensions.k8s.io/bfdprofiles.metallb.io \
    customresourcedefinition.apiextensions.k8s.io/bgpadvertisements.metallb.io \
    customresourcedefinition.apiextensions.k8s.io/bgppeers.metallb.io \
    customresourcedefinition.apiextensions.k8s.io/ipaddresspools.metallb.io \
    customresourcedefinition.apiextensions.k8s.io/l2advertisements.metallb.io \
    customresourcedefinition.apiextensions.k8s.io/communities.metallb.io


