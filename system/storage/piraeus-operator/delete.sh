arrayCRD=(
linstorsatelliteset
linstorcontroller
propscontainers.internal.linstor.linbit.com
secaccesstypes.internal.linstor.linbit.com
secaclmap.internal.linstor.linbit.com
layerdrbdresourcedefinitions.internal.linstor.linbit.com
layerdrbdvolumedefinitions.internal.linstor.linbit.com
layerdrbdvolumes.internal.linstor.linbit.com
layerresourceids.internal.linstor.linbit.com
layerstoragevolumes.internal.linstor.linbit.com
linstorversion.internal.linstor.linbit.com
nodenetinterfaces.internal.linstor.linbit.com
nodes.internal.linstor.linbit.com
nodestorpool.internal.linstor.linbit.com
resourcedefinitions.internal.linstor.linbit.com
resourcegroups.internal.linstor.linbit.com
resources.internal.linstor.linbit.com
resourcegroups.internal.linstor.linbit.com
resources.internal.linstor.linbit.com
secconfiguration.internal.linstor.linbit.com
secdfltroles.internal.linstor.linbit.com
secidentities.internal.linstor.linbit.com
secidrolemap.internal.linstor.linbit.com
secobjectprotection.internal.linstor.linbit.com
secroles.internal.linstor.linbit.com
sectyperules.internal.linstor.linbit.com
sectypes.internal.linstor.linbit.com
secaclmap.internal.linstor.linbit.com
spacehistory.internal.linstor.linbit.com
storpooldefinitions.internal.linstor.linbit.com
trackingdate.internal.linstor.linbit.com
volumedefinitions.internal.linstor.linbit.com
volumegroups.internal.linstor.linbit.com
volumes.internal.linstor.linbit.com
ebsremotes.internal.linstor.linbit.com
files.internal.linstor.linbit.com
keyvaluestore.internal.linstor.linbit.com
layerbcachevolumes.internal.linstor.linbit.com
layercachevolumes.internal.linstor.linbit.com
layerdrbdresourcedefinitions.internal.linstor.linbit.com
)


for i in "${arrayCRD[@]}" ; do
  kubectl delete --all $i
done

echo --- Delete linbit CRDs left
kubectl get crds | grep -o ".*.internal.linstor.linbit.com"  | xargs -i{} sh -c "kubectl delete {}"

echo --- Show linbit CRDs left
kubectl get crds | grep -o ".*.internal.linstor.linbit.com"  | xargs -i{} sh -c "echo {} && kubectl get {}"
NS=piraeus-operator

# Remove the finalizer blocking deletion
#kubectl -n $NS patch -p '{"metadata": {"$deleteFromPrimitiveList/finalizers": ["piraeus.linbit.com/protect-master-passphrase"]}}' secret piraeus-operator-passphrase
# Remove the secret
#kubectl -n $NS delete secret piraeus-operator-passphrase
kubectl -n $NS delete secret piraeus-operator-tls
