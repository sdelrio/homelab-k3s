#!/bin/sh

if [ ! -d charts ]; then
   echo "Building depencency..."
   helm dependency build 
fi

helm template \
    --namespace kube-system \
    nginx-external . \
    | kubectl -n kube-system apply -f -

#echo
#echo "# Check CRDs:"
#echo
#kubectl -n metallb-system wait --timeout=60s --for condition=Established \
#    customresourcedefinition.apiextensions.k8s.io/addresspools.metallb.io \
#    customresourcedefinition.apiextensions.k8s.io/bfdprofiles.metallb.io \
#    customresourcedefinition.apiextensions.k8s.io/bgpadvertisements.metallb.io \
#    customresourcedefinition.apiextensions.k8s.io/bgppeers.metallb.io \
#    customresourcedefinition.apiextensions.k8s.io/ipaddresspools.metallb.io \
#    customresourcedefinition.apiextensions.k8s.io/l2advertisements.metallb.io \
#    customresourcedefinition.apiextensions.k8s.io/communities.metallb.io

# erviceaccount/nginx-internal-ingress-nginx created
#configmap/nginx-internal-ingress-nginx-controller created
#clusterrole.rbac.authorization.k8s.io/nginx-internal-ingress-nginx created
#clusterrolebinding.rbac.authorization.k8s.io/nginx-internal-ingress-nginx created
#role.rbac.authorization.k8s.io/nginx-internal-ingress-nginx created
#rolebinding.rbac.authorization.k8s.io/nginx-internal-ingress-nginx created
#service/nginx-internal-ingress-nginx-controller-metrics created
#service/nginx-internal-ingress-nginx-controller-admission created
#service/nginx-internal-ingress-nginx-controller created
#deployment.apps/nginx-internal-ingress-nginx-controller created
#ingressclass.networking.k8s.io/nginx-internal created
#validatingwebhookconfiguration.admissionregistration.k8s.io/nginx-internal-ingress-nginx-admission created
#serviceaccount/nginx-internal-ingress-nginx-admission created
#clusterrole.rbac.authorization.k8s.io/nginx-internal-ingress-nginx-admission created
#clusterrolebinding.rbac.authorization.k8s.io/nginx-internal-ingress-nginx-admission created
#role.rbac.authorization.k8s.io/nginx-internal-ingress-nginx-admission created
#rolebinding.rbac.authorization.k8s.io/nginx-internal-ingress-nginx-admission created
#job.batch/nginx-internal-ingress-nginx-admission-create created
#job.batch/nginx-internal-ingress-nginx-admission-patch created
#error: unable to recognize "STDIN": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
#
