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
┊ k3s-1                                           ┊ SATELLITE  ┊ 10.6.3.202:3366 (PLAIN) ┊ Online ┊
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
┊ k3s-2                                          ┊ SATELLITE  ┊ 10.6.3.203:3366 (PLAIN) ┊ Online                                       ┊
┊ k3s-1                                          ┊ SATELLITE  ┊ 10.6.3.202:3366 (PLAIN) ┊ OFFLINE (Auto-eviction: 2023-01-17 21:44:36) ┊
┊ piraeus-operator-cs-controller-9758f794f-d8pjg ┊ CONTROLLER ┊ 10.42.0.95:3366 (PLAIN) ┊ Online                                       ┊
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
To cancel automatic eviction please consider the corresponding DrbdOptions/AutoEvict* properties on controller and / or node level
See 'linstor controller set-property --help' or 'linstor node set-property --help' for more details
root@piraeus-operator-cs-controller-9758f794f-d8pjg:/# linstor node restore k3s-1
ERROR:
    Node 'k3s-1' is neither evicted nor evacuated.
root@piraeus-operator-cs-controller-9758f794f-d8pjg:/# linstor node lost k3s-1
SUCCESS:
Description:
    Node 'k3s-1' deleted.
Details:
    Node 'k3s-1' UUID was: eba59576-9b80-4772-b827-00a015b2f7ab
SUCCESS:
    Notified 'k3s-2 ' that 'k3s-1' has been lost

╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
┊ Node                                           ┊ NodeType   ┊ Addresses               ┊ State   ┊
╞═════════════════════════════════════════════════════════════════════════════════════════════════╡
┊ k3s-2                                          ┊ SATELLITE  ┊ 10.6.3.203:3366 (PLAIN) ┊ Online  ┊
┊ k3s-1                                          ┊ SATELLITE  ┊ 10.6.3.202:3366 (PLAIN) ┊ OFFLINE ┊
┊ piraeus-operator-cs-controller-9758f794f-d8pjg ┊ CONTROLLER ┊ 10.42.0.95:3366 (PLAIN) ┊ Online  ┊
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯

root@k3s-1:/root# blkid
/dev/mapper/linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000: UUID="a776c5ede5d974e8" TYPE="drbd"
/dev/sda4: PARTUUID="f3b2ee14-a45d-47d5-b5de-30943ffb86c4"
/dev/sda2: UUID="b95f545b-2804-4559-9ebf-36aed0d08f44" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="f211ea08-459e-409c-9055-631ed72dcc14"
/dev/sda3: UUID="ff5381cd-4137-497b-9ee8-40ecac8ab742" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="4bc26084-84df-4c63-9bc0-23c61c98c0d1"
/dev/sda1: UUID="BE87-2007" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="e17cbcaf-f00c-4ecb-af41-a889c9fe5b89"

root@k3s-1:/root# wipefs -a /dev/mapper/linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000
/dev/mapper/linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000: 4 bytes were erased at offset 0x403ff03c (drbd): 83 74 02 6d
/dev/mapper/linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000: 2 bytes were erased at offset 0x00000438 (ext4): 53 ef

root@k3s-1:/root# blkid
/dev/sda2: UUID="b95f545b-2804-4559-9ebf-36aed0d08f44" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="f211ea08-459e-409c-9055-631ed72dcc14"
/dev/sda3: UUID="ff5381cd-4137-497b-9ee8-40ecac8ab742" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="4bc26084-84df-4c63-9bc0-23c61c98c0d1"
/dev/sda1: UUID="BE87-2007" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="e17cbcaf-f00c-4ecb-af41-a889c9fe5b89"
/dev/loop0: UUID="tsDcHp-CdDo-0yD7-QlBO-zCg0-kCj6-T6hkWr" TYPE="LVM2_member"
/dev/sda4: UUID="tsDcHp-CdDo-0yD7-QlBO-zCg0-kCj6-T6hkWr" TYPE="LVM2_member" PARTUUID="f3b2ee14-a45d-47d5-b5de-30943ffb86c4"

root@k3s-1:/root# wipefs -a /dev/loop0
/dev/loop0: 8 bytes were erased at offset 0x00000218 (LVM2_member): 4c 56 4d 32 20 30 30 31

root@k3s-1:/root# blkid
/dev/sda2: UUID="b95f545b-2804-4559-9ebf-36aed0d08f44" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="f211ea08-459e-409c-9055-631ed72dcc14"
/dev/sda3: UUID="ff5381cd-4137-497b-9ee8-40ecac8ab742" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="4bc26084-84df-4c63-9bc0-23c61c98c0d1"
/dev/sda1: UUID="BE87-2007" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="e17cbcaf-f00c-4ecb-af41-a889c9fe5b89"
/dev/sda4: PARTUUID="f3b2ee14-a45d-47d5-b5de-30943ffb86c4"

oot@k3s-1:/root# dmsetup ls
linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000	(253:4)
linstor_thinpool-thinpool	(253:3)
linstor_thinpool-thinpool-tpool	(253:2)
linstor_thinpool-thinpool_tdata	(253:1)
linstor_thinpool-thinpool_tmeta	(253:0)
root@k3s-1:/root# dmsetup remove linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000
root@k3s-1:/root# dmsetup remove linstor_thinpool-thinpool linstor_thinpool-thinpool-tpool linstor_thinpool-thinpool_tdata linstor_thinpool-thinpool_tmeta
root@k3s-1:/root# dmsetup remove linstor_thinpool-pvc--c5f7ee25--b3ed--447e--b66d--d92b3665f8fb_00000^C
root@k3s-1:/root# dmsetup ls
No devices found

root@piraeus-operator-cs-controller-79cddd6558-fxvtb:/# linstor node reconnect k3s-1
SUCCESS:
    Nodes [k3s-1] will be reconnected.
SUCCESS:
Description:
    Node 'k3s-1' authenticated
Details:
    Supported storage providers: [diskless, lvm, lvm_thin, file, file_thin, remote_spdk, openflex_target, ebs_init, ebs_target]
    Supported resource layers  : [drbd, luks, nvme, writecache, cache, openflex, storage]
    Unsupported storage providers:
        ZFS: 'cat /sys/module/zfs/version' returned with exit code 1
        ZFS_THIN: 'cat /sys/module/zfs/version' returned with exit code 1
        SPDK: IO exception occured when running 'rpc.py spdk_get_version': Cannot run program "rpc.py": error=2, No such file or directory
        EXOS: '/bin/bash -c cat /sys/class/sas_phy/*/sas_address' returned with exit code 1
              '/bin/bash -c cat /sys/class/sas_device/end_device-*/sas_address' returned with exit code 1

    Unsupported resource layers:
        BCACHE: IO exception occured when running 'make-bcache -h': Cannot run program "make-bcache": error=2, No such file or directory
INFO:
    Updated pvc-c5f7ee25-b3ed-447e-b66d-d92b3665f8fb DRBD auto verify algorithm to 'crct10dif-pclmul'

