#!/bin/sh

kustomize build \
    | kubectl apply -f -

echo
echo "# Check CRDs:"
echo
kubectl wait --timeout=60s --for condition=Established \
    customresourcedefinition.apiextensions.k8s.io/volumesnapshotclasses.snapshot.storage.k8s.io \
    customresourcedefinition.apiextensions.k8s.io/volumesnapshotcontents.snapshot.storage.k8s.io \
    customresourcedefinition.apiextensions.k8s.io/volumesnapshots.snapshot.storage.k8s.io

