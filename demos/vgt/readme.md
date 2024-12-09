# VLAN Guest Tagging

Pass multiple VLANs to a single interface on virtual machine guest on OpenShift via 802.1q trunk.

Choose only one option at a time: [ovs-bridge](overlays/ovs-bridge) or [linux-bridge](overlays/linux-bridge).

## ovs-bridge

* Test setup for ovn-kubernetes localnet topology (ovs-bridge). Truns out this is not yet supported. https://issues.redhat.com/browse/RFE-6831
[![asciicast](https://asciinema.org/a/693745.svg)](https://asciinema.org/a/693745)


* [br-trunk OVS Bridge](networking/components/br-trunk/ovs-bridge/) (not tested)
* [trunk Network Attachment](networking/components/trunk/ovs-bridge/) (fail)

## linux-bridge

Adding a 2nd linux bridge `br-trunk` to the NIC (eg ens224) underlying the OVS-bridge `br-vmdata` does work.

See
* [br-trunk Linux Bridge](networking/components/br-trunk/linux-bridge/) (pass)
* [trunk Network Attachment](networking/components/trunk/linux-bridge/) (pass)
