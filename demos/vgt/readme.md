# VLAN Guest Tagging

Test the passing of multiple VLANs to a single virtual machine guest interface on OpenShift Virtualization via 802.1q trunk.

> [!NOTE]
> OpenStack also [supports this](https://docs.redhat.com/en/documentation/red_hat_openstack_services_on_openshift/18.0/html/managing_networking_resources/vlan-aware-instances_rhoso-mngnet#vlan-aware-instances_rhoso-mngnet).

# Setup

Using linux-bridge and ovs-bridge on the same NIC is not supported. In my test the ovs-bridge stopped working.

Configure only one option at a time: [ovs-bridge](overlays/ovs-bridge) or [linux-bridge](overlays/linux-bridge).

> [!IMPORTANT]
> Generally ovs-bridge is the preferred technology, but this testing has confirmed that at this time, linux-bridge is the only option that supports VGT functionality.

## Cleanup

> [!NOTE]
> NNCP does not have a state controller, so it cleanup is not as straightforward as deleting the NNCP. A NNCP should be patched to reverse its affect and allowed to reconcile before deleting.


## ovs-bridge

```bash
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

## linux-bridge

```bash
oc apply -k overlays/linux-bridge
```

Test setup for cnv-bridge ove linux bridge.
This does work. VLAN tags visible on VM.

* [br-trunk Linux Bridge](components/br-trunk/linux-bridge/) (pass)
* [trunk Network Attachment](components/trunk/linux-bridge/) (pass)

```bash
oc patch -n demo-vgt nncp/br-trunk --type=json \
  -p='[{"op":"replace", "path":"/spec/desiredState/interfaces/1/state", "value": "absent"}]'

oc wait nncp/br-trunk --for=condition=Available=True

oc delete -k overlays/linux-bridge
```


# Demo

## OVS-Bridge to Localnet Net-Attach-Def

<!-- * [![asciicast](https://asciinema.org/a/693745.svg)](https://asciinema.org/a/693745) -->
* [demo-script-ovs.sh](demo-script-ovs.sh)

## Linx-Bridge to cnv-bridge Net-Attach-Def

* Local [demo-script-linux-br.sh](demo-script-linux-br.sh)
* VM [demo](base/scripts/demo)
* VM [netsetup](base/scripts/netsetup)

[![asciicast](https://asciinema.org/a/695824.svg)](https://asciinema.org/a/695824)
