---
marp: true
theme: mylogo
paginate: true
size: 4k
---
<!-- _paginate: skip -->
<!-- _class: title invert -->
<!-- _footer: '[github.com/dlbewley/demo-virt](https://github.com/dlbewley/demo-virt/)' -->
![bg grayscale opacity:20%](../../img/openshift.png)
# OpenShift Virtualization API / CLI Management

### Dale Bewley

> ### Specialist SA
> NA West OpenShift 🐯 Team
> Red Hat

![logo Logo](../../img/me-gta5.png)

---
<!-- header: Command line tools -->

# Command line tools

## `virtctl`
> **Virtualization Control**
> Perform virtual machine related operations on command line or in scripts.

# `oc`
> **OpenShift Client**
> Interact with OpenShift and resource APIs known as "kinds"

---
<!-- header: "Command line tools - oc" -->

# List [Available APIs](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18#API%20Reference)
```bash
oc api-resources
```

```bash
$ oc api-resources --api-group=kubevirt.io
NAME                                SHORTNAMES             APIVERSION       NAMESPACED   KIND
kubevirts                           kv,kvs                 kubevirt.io/v1   true         KubeVirt
virtualmachineinstancemigrations    vmim,vmims             kubevirt.io/v1   true         VirtualMachineInstanceMigration
virtualmachineinstancepresets       vmipreset,vmipresets   kubevirt.io/v1   true         VirtualMachineInstancePreset
virtualmachineinstancereplicasets   vmirs,vmirss           kubevirt.io/v1   true         VirtualMachineInstanceReplicaSet
virtualmachineinstances             vmi,vmis               kubevirt.io/v1   true         VirtualMachineInstance
virtualmachines                     vm,vms                 kubevirt.io/v1   true         VirtualMachine
```

---

# View API Specification
```bash
oc explain
```
```bash
$ oc explain virtualmachine
GROUP:      kubevirt.io
KIND:       VirtualMachine
VERSION:    v1

DESCRIPTION:
    VirtualMachine handles the VirtualMachines that are not running
    or are in a stopped state
    The VirtualMachine contains the template to create the
    VirtualMachineInstance. It also mirrors the running state of the created
    VirtualMachineInstance in its status.
...
```

---

# View API Specification

```bash
$ oc explain virtualmachine.spec.template.spec.domain
GROUP:      kubevirt.io
KIND:       VirtualMachine
VERSION:    v1

FIELD: domain <Object>

DESCRIPTION:
    Specification of the desired behavior of the VirtualMachineInstance on the
    host.

FIELDS:
  chassis       <Object>
    Chassis specifies the chassis info passed to the domain.

  clock <Object>
    Clock sets the clock and timers of the vmi.

  cpu   <Object>
    CPU allow specified the detailed CPU topology inside the vmi.

  devices       <Object> -required-
    Devices allows adding disks, network interfaces, and others
    ...
```

---
<!-- header: Command line tools - oc -->

# Create Resources from YAML
```bash
oc apply
```
# Create Resources from Template
```bash
oc process
```

# Modifying Resources
```bash
oc edit
oc patch
```

---
<!-- header: Command line tools - virtctl -->

Available `virtctl` Commands:
```shell
virtctl controls virtual machine related operations on your kubernetes cluster.

  addvolume         add a volume to a running VM
  adm               Administrate KubeVirt configuration.
  completion        Generate the autocompletion script for the specified shell
  console           Connect to a console of a virtual machine instance.
  create            Create a manifest for the specified Kind.
  credentials       Manipulate credentials on a virtual machine.
  expand            Return the VirtualMachine object with expanded instancetype and preference.
  expose            Expose a virtual machine instance, virtual machine, or virtual
                    machine instance replica set as a new service.
  fslist            Return full list of filesystems available on the guest machine.
  guestfs           Start a shell into the libguestfs pod
  guestosinfo       Return guest agent info about operating system.
  help              Help about any command
  image-upload      Upload a VM image to a DataVolume/PersistentVolumeClaim.
  memory-dump       Dump the memory of a running VM to a pvc
  migrate           Migrate a virtual machine.
  migrate-cancel    Cancel migration of a virtual machine.
  pause             Pause a virtual machine
  permitted-devices List the permitted devices for vmis.
  port-forward      Forward local ports to a virtualmachine or virtualmachineinstance.
  removevolume      remove a volume from a running VM
  restart           Restart a virtual machine.
  scp               SCP files from/to a virtual machine instance.
  soft-reboot       Soft reboot a virtual machine instance
  ssh               Open a SSH connection to a virtual machine instance.
  start             Start a virtual machine.
  stop              Stop a virtual machine.
  unpause           Unpause a virtual machine
  usbredir          Redirect an USB device to a virtual machine instance.
  userlist          Return full list of logged in users on the guest machine.
  version           Print the client and server version information.
  vmexport          Export a VM volume.
  vnc               Open a vnc connection to a virtual machine instance.
```
---
<!-- _class: invert -->
<!-- header: virtctl - Creating VMs -->

# 👷🏻‍♀️ Creating VMs


---
# Instance Types

## VirtualMachineInstancetype
> Details of VM instance type which can be namespaced

## VirtualMachineClusterInstancetype 
> Cluster wide instance types administered by admin.

### `u1.medium` 

```json
$ oc get vmclusterinstancetype u1.medium -o jsonpath='{.spec}'
{"cpu":{"guest":1},"memory":{"guest":"4Gi"}}%
```


---
# Datasources

* DataSources provide a reference to a source of data to provision a volume from.
* Eg. a PVC or a snapshot.
* Metadata like labels can influence their default use.

```bash
$ oc get datasources -n openshift-virtualization-os-images
NAME              AGE
centos-stream10   43d
centos-stream9    43d
fedora            43d
rhel10-beta       43d
rhel7             43d
rhel8             43d
rhel9             43d
win10             43d
...
```

---
# rhel9 Datasource
```bash
$ oc get datasource -n openshift-virtualization-os-images rhel9 -o yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  annotations:
    operator-sdk/primary-resource: openshift-cnv/ssp-kubevirt-hyperconverged
    operator-sdk/primary-resource-type: SSP.ssp.kubevirt.io
  labels:
    app.kubernetes.io/component: storage
    app.kubernetes.io/managed-by: cdi-controller
    app.kubernetes.io/part-of: hyperconverged-cluster
    app.kubernetes.io/version: 4.18.2
    cdi.kubevirt.io/dataImportCron: rhel9-image-cron
    instancetype.kubevirt.io/default-instancetype: u1.medium # <----
    instancetype.kubevirt.io/default-preference: rhel.9
    kubevirt.io/dynamic-credentials-support: "true"
  name: rhel9
  namespace: openshift-virtualization-os-images
spec:
  source:
    snapshot:
      name: rhel9-dd6a5c9fb09e
      namespace: openshift-virtualization-os-images
...
```

---
# C️reate a VM with virtctl

Create VM with default instance type for the datasource (`u1.medium`):
```bash
$ virtctl create vm \
  --name rhel-9-minimal \
  --volume-import "type:ds,src:openshift-virtualization-os-images/rhel9" \
  | tee vm.yaml | oc create -f -
```

Create VM with specific instance type (`u1.large`):
```bash
$ virtctl create vm \
  --name rhel-9-minimal \
  --instancetype u1.large \
  --volume-import "type:ds,src:openshift-virtualization-os-images/rhel9" \
```

---
<!-- _class: invert -->
<!-- header: virtctl - Controlling VMs -->

# 🕹️ Controlling VMs

---
# 🕹️ Controlling VMs
Available `virtctl` Commands:
```bash
  image-upload      Upload a VM image to a DataVolume/PersistentVolumeClaim.
  migrate           Migrate a virtual machine.
  migrate-cancel    Cancel migration of a virtual machine.
  pause             Pause a virtual machine
  restart           Restart a virtual machine.
  soft-reboot       Soft reboot a virtual machine instance
  start             Start a virtual machine.
  stop              Stop a virtual machine.
  unpause           Unpause a virtual machine
  usbredir          Redirect an USB device to a virtual machine instance.
  vmexport          Export a VM volume.
  vnc               Open a vnc connection to a virtual machine instance.
```

---
<!-- _class: invert -->
<!-- header: virtctl - Investigating VMs -->

# 🔎 Investigating VMs

---
# 🔎 Investigating VMs

Available `virtctl` Commands:
```bash
  completion        Generate the autocompletion script for the specified shell
  console           Connect to a console of a virtual machine instance.
  fslist            Return full list of filesystems available on the guest machine.
  guestfs           Start a shell into the libguestfs pod
  guestosinfo       Return guest agent info about operating system.
  memory-dump       Dump the memory of a running VM to a pvc
  permitted-devices List the permitted devices for vmis.
  scp               SCP files from/to a virtual machine instance.
  ssh               Open a SSH connection to a virtual machine instance.
  userlist          Return full list of logged in users on the guest machine.
  vnc               Open a vnc connection to a virtual machine instance.
```

---
# OS Info

```bash
virtctl guestosinfo rhel-9-minimal | jq .os
{
  "name": "Red Hat Enterprise Linux",
  "kernelRelease": "5.14.0-503.11.1.el9_5.x86_64",
  "version": "9.5 (Plow)",
  "prettyName": "Red Hat Enterprise Linux 9.5 (Plow)",
  "versionId": "9.5",
  "kernelVersion": "#1 SMP PREEMPT_DYNAMIC Mon Sep 30 11:54:45 EDT 2024",
  "machine": "x86_64",
  "id": "rhel"
}
```

---

# Filesystems

List filesystems in a VM

```json
$ virtctl fslist rhel-9-minimal
{
  "metadata": {},
  "items": [
    {
      "diskName": "vda2",
      "mountPoint": "/boot/efi",
      "fileSystemType": "vfat",
      "usedBytes": 7368704,
      "totalBytes": 209489920,
      "disk": [
        {
          "busType": "virtio"
        }
      ]
    },
    ...
```
---
<!-- _class: invert -->
<!-- header: virtctl - Modifying VMs -->

# 🛠️ Modifying VMs

---
# 🛠️ Modifying VMs

Available `virtctl` Commands:
```bash
  addvolume         add a volume to a running VM
  create            Create a manifest for the specified Kind.
  credentials       Manipulate credentials on a virtual machine.
  expose            Expose a virtual machine instance, virtual machine,
                    or virtual machine instance replica set as a new service.
  port-forward      Forward local ports to a virtualmachine or virtualmachineinstance.
  removevolume      remove a volume from a running VM
```
---
# Change VM CPU and Memory

Options:
* Change the VirtualMachine spec with `oc edit` or `oc patch`

---
<!-- header: oc - Modifying VMs -->
# Destroy VM

```bash
virtctl stop vm rhel-server -n namespace
oc delete vm rhel-server -n namespace
```

---
# Managing VM Storage
## `VirtualMachineSnapshot` Resource

```yaml
apiVersion: snapshot.kubevirt.io/v1beta1
kind: VirtualMachineSnapshot
metadata:
  name: <snapshot_name>
spec:
  source:
    apiGroup: kubevirt.io
    kind: VirtualMachine
    name: <vm_name>
```

---

# Managing VM Storage
## Expanding VM Disk Size

Use `oc edit` or `oc patch` command to modify the PVC request size
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
   name: imported-volume-8w4mq
spec:
  accessModes:
     - ReadWriteMany
  resources:
    requests:
       storage: 30Gi # <----
# ...
```

---

## Expanding VM Disk Size

```bash
$ oc patch pvc imported-volume-8w4mq --type=json \
  -p='[{"op": "replace", "path": "/spec/resources/requests/storage", "value": "31Gi"}]'
persistentvolumeclaim/imported-volume-8w4mq patched
```
---

## Expanding VM Disk Size

```
$ oc describe pvc imported-volume-8w4mq
...
Events:
  Type     Reason                      Age   From                                                 Message
  ----     ------                      ----  ----                                                 -------
  Normal   Resizing                    27s   external-resizer openshift-storage.rbd.csi.ceph.com  External resizer is resizing volume pvc-c9172b7f-1184-4b41-9f5c-d24c8dec8d11
  Warning  ExternalExpanding           27s   volume_expand                                        waiting for an external controller to expand this PVC
  Normal   VolumeResizeSuccessful      27s   external-resizer openshift-storage.rbd.csi.ceph.com  Resize volume succeeded
  Normal   FileSystemResizeSuccessful  1s    kubelet                                              MountVolume.NodeExpandVolume succeeded for volume "pvc-c9172b7f-1184-4b41-9f5c-d24c8dec8d11" worker-5
```


---
<!-- _class: invert -->

# ⚖️ Resource Quotas

---

# ⚖️ Resource Quotas

Example Storage Quotas on a Project
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-consumption
spec:
  hard:
    persistentvolumeclaims: "10" 
    requests.storage: "50Gi" 
    gold.storageclass.storage.k8s.io/requests.storage: "10Gi" 
    silver.storageclass.storage.k8s.io/requests.storage: "20Gi" 
    silver.storageclass.storage.k8s.io/persistentvolumeclaims: "5" 
    bronze.storageclass.storage.k8s.io/requests.storage: "0" 
    bronze.storageclass.storage.k8s.io/persistentvolumeclaims: "0" 
    requests.ephemeral-storage: 2Gi 
    limits.ephemeral-storage: 4Gi 
```

---
<!-- class: title invert logo -->
<!-- header: '' -->

![bg grayscale opacity:20%](../../img/openshift.png)
![logo Logo](../../img/me-gta5.png)

# Thank you

## Resources
* [API References](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18#API%20Reference)
* [Creating VMs on CLI](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/virtualization/advanced-vm-creation#virt-creating-vm-cli_virt-creating-vms-cli)
* [Resource Quotas](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/scalability_and_performance/compute-resource-quotas#admin-quota-overview_using-quotas-and-limit-ranges)
* [Expanding Disks](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/virtualization/managing-vms#virt-expanding-vm-disks)
* [VM Snapshots](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/virtualization/backup-and-restore#virt-about-vm-snapshots_virt-backup-restore-snapshots)