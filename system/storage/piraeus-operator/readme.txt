# Charts for closed linbit operator

https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#ch-kubernetes
https://www.cncf.io/wp-content/uploads/2020/08/0513-Piraeus-CNCF-Webinar-1.pdf

helm repo add linstor https://charts.linstor.io
helm install linstor-op linstor/linstor

> Note: linstor/linstor is the paid version

# Charts in piraeus.io

https://github.com/piraeusdatastore/helm-charts

curl -s https://piraeus.io/helm-charts/index.yaml | yq eval '.entries | keys' - | head

- linstor-affinity-controller
- [linstor-scheduler](https://artifacthub.io/packages/helm/piraeus-charts/linstor-scheduler)
- piraeus-ha-controller
- snapshot-controller
- snapshot-validation-webhook
- https://github.com/piraeusdatastore/linstor-scheduler-extender

# backup before upgrade

https://github.com/piraeusdatastore/piraeus-operator/blob/master/doc/k8s-backend.md
https://github.com/piraeusdatastore/piraeus-operator/blob/master/doc/k8s-backend.md#manually-creating-a-backup-of-linstor-internal-resources

# snapshots

https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#s-kubernetes-snapshots

# sample values

etcd:
  enabled: false
operator:
  controller:
    dbConnectionURL: k8s
  satelliteSet:
    kernelModuleInjectionImage: quay.io/piraeusdatastore/drbd9-jammy
    storagePools:
      # https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#_configuring_lvm_storage_pools
      lvmPools:
      - name: lvm-thick
        volumeGroup: drbdpool
      # https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#_configuring_lvm_thin_pools
      lvmThinPools:
      - name: lvm-thin
        thinVolume: thinpool
        volumeGroup: ""
        devicePaths:
        - /dev/sdx

# StoragePools after install:  kubectl edit LinstorSatelliteSet.linstor.linbit.com <satellitesetname>

root@piraeus-operator-cs-controller-7955bb4b4d-h2rfr:/# linstor storage-pool list
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ StoragePool          ┊ Node  ┊ Driver   ┊ PoolName                  ┊ FreeCapacity ┊ TotalCapacity ┊ CanSnapshots ┊ State ┊ SharedName ┊
╞════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ DfltDisklessStorPool ┊ k3s-1 ┊ DISKLESS ┊                           ┊              ┊               ┊ False        ┊ Ok    ┊            ┊
┊ lvm-thin             ┊ k3s-1 ┊ LVM_THIN ┊ linstor_thinpool/thinpool ┊   299.40 GiB ┊    299.85 GiB ┊ True         ┊ Ok    ┊            ┊
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

root@piraeus-operator-cs-controller-7955bb4b4d-kgz2x:/# linstor physical-storage list -p
+-----------------------------------------------+
| Size         | Rotational | Nodes             |
|===============================================|
| 408021893120 | False      | k3s-1[/dev/loop0] |
+-----------------------------------------------+

root@piraeus-operator-cs-controller-7955bb4b4d-h2rfr:/# linstor node list
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ Node                                            ┊ NodeType   ┊ Addresses               ┊ State  ┊
╞═════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ k3s-1                                           ┊ SATELLITE  ┊ 10.6.3.203:3366 (PLAIN) ┊ Online ┊
┊ piraeus-operator-cs-controller-7955bb4b4d-h2rfr ┊ CONTROLLER ┊ 10.42.0.15:3366 (PLAIN) ┊ Online ┊
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯

root@piraeus-operator-cs-controller-7955bb4b4d-h2rfr:/# linstor resource list
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ ResourceName                             ┊ Node  ┊ Port ┊ Usage  ┊ Conns ┊    State ┊ CreatedOn           ┊
╞═══════════════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ pvc-8b1c353c-ec32-4f43-a379-9b0924439b5b ┊ k3s-1 ┊ 7002 ┊ InUse  ┊ Ok    ┊ UpToDate ┊ 2022-10-15 13:38:09 ┊
┊ pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 ┊ k3s-1 ┊ 7001 ┊ Unused ┊ Ok    ┊ UpToDate ┊ 2022-10-15 13:38:08 ┊
┊ pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 ┊ k3s-1 ┊ 7000 ┊ Unused ┊ Ok    ┊ UpToDate ┊ 2022-10-15 13:38:07 ┊
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────╯

## manual delete resources

root@piraeus-operator-cs-controller-7955bb4b4d-h2rfr:/# linstor resource delete k3s-1 pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8
SUCCESS:
Description:
    Node: k3s-1, Resource: pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 preparing for deletion.
Details:
    Node: k3s-1, Resource: pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 UUID is: e814917b-42a7-4fbf-b660-e577bc3e93ae
SUCCESS:
    Preparing deletion of resource on 'k3s-1'
SUCCESS:
Description:
    Node: k3s-1, Resource: pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 marked for deletion.
Details:
    Node: k3s-1, Resource: pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 UUID is: e814917b-42a7-4fbf-b660-e577bc3e93ae
SUCCESS:
    Cleaning up 'pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8' on 'k3s-1'
SUCCESS:
Description:
    Node: k3s-1, Resource: pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 deletion complete.
Details:
    Node: k3s-1, Resource: pvc-ca93fe68-aa7e-4049-9271-fc86c87fe3a8 UUID was: e814917b-42a7-4fbf-b660-e577bc3e93ae
root@piraeus-operator-cs-controller-7955bb4b4d-h2rfr:/# linstor resource list
╭───────────────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ ResourceName                             ┊ Node  ┊ Port ┊ Usage  ┊ Conns ┊    State ┊ CreatedOn           ┊
╞═══════════════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ pvc-8b1c353c-ec32-4f43-a379-9b0924439b5b ┊ k3s-1 ┊ 7002 ┊ InUse  ┊ Ok    ┊ UpToDate ┊ 2022-10-15 13:38:09 ┊
┊ pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 ┊ k3s-1 ┊ 7000 ┊ Unused ┊ Ok    ┊ UpToDate ┊ 2022-10-15 13:38:07 ┊
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────╯
root@piraeus-operator-cs-controller-7955bb4b4d-h2rfr:/# linstor resource delete k3s-1 pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0
SUCCESS:
Description:
    Node: k3s-1, Resource: pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 preparing for deletion.
Details:
    Node: k3s-1, Resource: pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 UUID is: ee7372bb-9197-4cb4-a520-8326c99973b9
SUCCESS:
    Preparing deletion of resource on 'k3s-1'
SUCCESS:
Description:
    Node: k3s-1, Resource: pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 marked for deletion.
Details:
    Node: k3s-1, Resource: pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 UUID is: ee7372bb-9197-4cb4-a520-8326c99973b9
SUCCESS:
    Cleaning up 'pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0' on 'k3s-1'
SUCCESS:
Description:
    Node: k3s-1, Resource: pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 deletion complete.
Details:
    Node: k3s-1, Resource: pvc-d717e7b5-66a1-4962-b7a8-840b3ab92bc0 UUID was: ee7372bb-9197-4cb4-a520-8326c99973b9

# Manual delete storage pool

root@piraeus-operator-cs-controller-cdcf984-wgkh6:/# linstor storage-pool delete k3s-1 lvm-thin
SUCCESS:
Description:
    Node: k3s-1, Storage pool name: lvm-thin deleted.
Details:
    Node: k3s-1, Storage pool name: lvm-thin UUID was: e6de1f5b-41ef-4f32-849a-50a3ca2fc444
root@piraeus-operator-cs-controller-cdcf984-wgkh6:/# linstor physical-storage create-device-pool --pool-name thinpool   LVMTHIN k3s-1 /dev/loop0 --storage-pool lvm-thin
SUCCESS:
    (k3s-1) PV for device '/dev/loop0' created.
SUCCESS:
    (k3s-1) VG for devices [/dev/loop0] with name 'linstor_thinpool' created.
SUCCESS:
    (k3s-1) Thin-pool 'thinpool' in LVM-pool 'linstor_thinpool' created.
SUCCESS:
    Successfully set property key(s): StorDriver/StorPoolName
SUCCESS:
Description:
    New storage pool 'lvm-thin' on node 'k3s-1' registered.
Details:
    Storage pool 'lvm-thin' on node 'k3s-1' UUID is: bcd8c49e-8bdb-4e48-8497-1e9e03b093b9
SUCCESS:
    (k3s-1) Changes applied to storage pool 'lvm-thin'

root@piraeus-operator-cs-controller-cdcf984-wgkh6:/# linstor storage-pool list
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ StoragePool          ┊ Node  ┊ Driver   ┊ PoolName                  ┊ FreeCapacity ┊ TotalCapacity ┊ CanSnapshots ┊ State ┊ SharedName ┊
╞════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ DfltDisklessStorPool ┊ k3s-1 ┊ DISKLESS ┊                           ┊              ┊               ┊ False        ┊ Ok    ┊            ┊
┊ lvm-thin             ┊ k3s-1 ┊ LVM_THIN ┊ linstor_thinpool/thinpool ┊   379.81 GiB ┊    379.81 GiB ┊ True         ┊ Ok    ┊            ┊
╰────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

root@piraeus-operator-cs-controller-cdcf984-wgkh6:/# linstor physical-storage l
╭───────────────────────────╮
┊ Size ┊ Rotational ┊ Nodes ┊
╞═══════════════════════════╡
╰───────────────────────────╯

# Auto-eviction

https://linbit.com/blog/linstors-auto-evict/

╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ Node                                           ┊ NodeType   ┊ Addresses               ┊ State                                        ┊
╞══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ asus-0                                         ┊ SATELLITE  ┊ 10.6.3.203:3366 (PLAIN) ┊ Online                                       ┊
┊ nuc-2                                          ┊ SATELLITE  ┊ 10.6.3.202:3366 (PLAIN) ┊ OFFLINE (Auto-eviction: 2023-01-17 21:44:36) ┊
┊ piraeus-operator-cs-controller-9758f794f-d8pjg ┊ CONTROLLER ┊ 10.42.0.95:3366 (PLAIN) ┊ Online                                       ┊
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
To cancel automatic eviction please consider the corresponding DrbdOptions/AutoEvict* properties on controller and / or node level
See 'linstor controller set-property --help' or 'linstor node set-property --help' for more details
root@piraeus-operator-cs-controller-9758f794f-d8pjg:/# linstor node restore nuc-2
ERROR:
    Node 'nuc-2' is neither evicted nor evacuated.
root@piraeus-operator-cs-controller-9758f794f-d8pjg:/# linstor node lost nuc-2
SUCCESS:
Description:
    Node 'nuc-2' deleted.
Details:
    Node 'nuc-2' UUID was: eba59576-9b80-4772-b827-00a015b2f7ab
SUCCESS:
    Notified 'asus-0' that 'nuc-2' has been lost

╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ Node                                           ┊ NodeType   ┊ Addresses               ┊ State   ┊
╞═════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ asus-0                                         ┊ SATELLITE  ┊ 10.6.3.203:3366 (PLAIN) ┊ Online  ┊
┊ nuc-2                                          ┊ SATELLITE  ┊ 10.6.3.202:3366 (PLAIN) ┊ OFFLINE ┊
┊ piraeus-operator-cs-controller-9758f794f-d8pjg ┊ CONTROLLER ┊ 10.42.0.95:3366 (PLAIN) ┊ Online  ┊
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯

