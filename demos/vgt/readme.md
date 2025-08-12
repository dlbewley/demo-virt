# VLAN Guest Tagging

> [!IMPORTANT]
> See my [blog post](https://guifreelife.com/blog/2025/01/02/OpenShift-Virtualization-VLAN-Guest-Tagging/) on this topic.

Test the passing of multiple VLANs to a single virtual machine guest interface on OpenShift Virtualization via 802.1q trunk.

> [!NOTE]
> OpenStack also [supports this](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/managing_networking_resources/vlan-aware-instances_rhoso-mngnet#vlan-aware-instances_rhoso-mngnet).

# Setup

Using linux-bridge and ovs-bridge on the same NIC is not supported. Configure only one option at a time: [ovs-bridge](overlays/ovs-bridge) or [linux-bridge](overlays/linux-bridge).

## Prereqs

**Node Selector**

Identify a selector for the test nodes to test with. In my case that is:
`"machine.openshift.io/cluster-api-machineset": "hub-v57jl-cnv"`

**Trunked Network Interface**

Identify a NIC to use as the uplink carrying the trunk. This NIC should not be in use already. In my case the NIC is `ens256`.

**IP Forwarding**

In OCP 4.18 and below IP forwarding was on by default for all interfaces.
```bash
# 4.18 has defaults:
cat /proc/sys/net/ipv4/conf/default/forwarding
1
cat /proc/sys/net/ipv4/conf/all/forwarding
1
```

In OCP 4.19 this has changed.
```
# 4.19 has defaults:
cat /proc/sys/net/ipv4/conf/default/forwarding
0
cat /proc/sys/net/ipv4/conf/all/forwarding
0
```

This means we need to enable IP forwarding on our linux bridge via [tuned.yaml](components/br-trunk/linux-bridge/tuned.yaml).

## linux-bridge

Here are the main components used:

* ["br-trunk" Linux Bridge NNCP](components/br-trunk/linux-bridge/)
* [trunk Network Attachment Definition](components/trunk/linux-bridge/)

Update the:
1) linux-bridge [overlay kustomization.yaml](overlays/linux-bridge/kustomization.yaml) with the NIC name and selector identified in [Prereqs](#prereqs)
1) [tuned.yaml](components/br-trunk/linux-bridge/tuned.yaml) profile with the NIC name and selector identified in [Prereqs](#prereqs)

```bash
# sanity check the prereqs are in place (nic and selector)
oc kustomize overlays/linux-bridge | kfilt -k nodenetworkconfigurationpolicy,tuned

# apply the settings
oc apply -k overlays/linux-bridge
```

Login to the node and expect to see `eth1.1924` got an IP from DHCP. You can also [use tcpdump](https://gist.github.com/dlbewley/9acff618d854e679c7ac04888ec9abb0) to confirm a trunk is visible: `tcpdump -enni eth1 ether proto 0x8100`

If packets are not flowing (i.e. DHCP fails) check IP forwarding on the nodes matching the selector like this. Adjust the list of interface names as appropriate. You want to see `1` on your int.

```bash
for node in $(oc get nodes -l machine.openshift.io/cluster-api-machineset=hub-v57jl-cnv -o name); do
  echo "# $node";
  oc debug $node -- grep -H ^ /host/proc/sys/net/ipv4/conf/{ens192,ens224,ens256,all,default}/forwarding 2>/dev/null;
done

# node/hub-v57jl-cnv-25fpw
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
...
```

**Cleanup**

```bash
oc patch -n demo-vgt nncp/br-trunk --type=json \
  -p='[{"op":"replace", "path":"/spec/desiredState/interfaces/1/state", "value": "absent"}]'

oc wait nncp/br-trunk --for=condition=Available=True

oc delete -k overlays/linux-bridge
```

## ovs-bridge

> [!IMPORTANT]
> Generally ovs-bridge is the preferred technology, but this testing has confirmed that at this time, linux-bridge is the only option that supports VGT functionality.
>
> Here are the related issues:
> - https://issues.redhat.com/browse/RFE-6831
> - https://issues.redhat.com/browse/CORENET-5642

Update the ovs-bridge [overlay kustomization.yaml](overlays/ovs-bridge/kustomization.yaml) with the NIC name and selector identified in [Prereqs](#prereqs)

```bash
# sanity check the prereqs are in place
oc kustomize overlays/ovs-bridge | kfilt -k nodenetworkconfigurationpolicy

# apply the settings
oc apply -k overlays/ovs-bridge
```

Test setup for ovn-kubernetes localnet topology (ovs-bridge).

* [br-trunk OVS Bridge](components/br-trunk/ovs-bridge/) (not tested)
* [trunk Network Attachment](components/trunk/ovs-bridge/) (fail)

Turns out this is not yet supported. https://issues.redhat.com/browse/RFE-6831

**Cleanup**

```bash
oc patch -n demo-vgt nncp/br-trunk --type=json \
  -p='[{"op":"replace", "path":"/spec/desiredState/interfaces/1/state", "value": "absent"}]'

oc patch -n demo-vgt nncp/ovs-bridge-mapping-trunk --type=json \
  -p='[{"op":"replace", "path":"/spec/desiredState/ovn/bridge-mappings/0/state", "value": "absent"}

oc wait nncp/br-trunk --for=condition=Available=True
oc wait nncp/ovs-bridge-mapping-trunk --for=condition=Available=True

oc delete -k overlays/ovs-bridge
```

## Cleanup

> [!NOTE]
> NNCP does not have a state controller, so cleanup is not as straightforward as deleting the NNCP. A NNCP should be patched to reverse its affect and then allowed to reconcile before finally deleting it.

# Demo

## OVS-Bridge to Localnet Net-Attach-Def

<!-- * [![asciicast](https://asciinema.org/a/693745.svg)](https://asciinema.org/a/693745) -->
* [demo-script-ovs.sh](demo-script-ovs.sh)

## Linx-Bridge to cnv-bridge Net-Attach-Def

* Local [demo-script-linux-br.sh](demo-script-linux-br.sh)
* VM [demo](base/scripts/demo)
* VM [netsetup](base/scripts/netsetup)

[![asciicast](https://asciinema.org/a/695824.svg)](https://asciinema.org/a/695824)
