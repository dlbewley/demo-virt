# VLAN Guest Tagging

Pass multiple VLANs to a single virtual machine guest interface on OpenShift via 802.1q trunk.

Configure only one option at a time: [ovs-bridge](overlays/ovs-bridge) or [linux-bridge](overlays/linux-bridge).

Generally ovs-bridge is the preferred technology, but this testing confirmed a second use case that prefers (requires) traditional linux-bridge; this use case and the case when a VM must have 2 NICs on the same NAD.

## ovs-bridge

Test setup for ovn-kubernetes localnet topology (ovs-bridge). Truns out this is not yet supported. https://issues.redhat.com/browse/RFE-6831

* [br-trunk OVS Bridge](networking/components/br-trunk/ovs-bridge/) (not tested)
* [trunk Network Attachment](networking/components/trunk/ovs-bridge/) (fail)

## linux-bridge

Creating 2nd linux-bridge `br-trunk` on the NIC (eg ens224) does work.

Using linux-bridge and ovs-bridge on the same NIC is not supported. In my test the ovs-bridge stopped working.

* [br-trunk Linux Bridge](networking/components/br-trunk/linux-bridge/) (pass)
* [trunk Network Attachment](networking/components/trunk/linux-bridge/) (pass)

## Demo

### OVS-Bridge to Localnet Net-Attach-Def

* [![asciicast](https://asciinema.org/a/693745.svg)](https://asciinema.org/a/693745)
* [demo-script.sh](demo-script.sh)

### Linx-Bridge to cnv-bridge Net-Attach-Def

* Not yet recorded. It works though.
