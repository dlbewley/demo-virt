This does not work as of OCP 4.17

https://ovn-kubernetes.io/features/multiple-networks/multi-homing/?t#sharing-the-same-physical-network-mapping

Instead of adding a OVN bridge mapping via NNCP per NAD add a physicalNetworkName to each NAD and then create a single mapping for that common string.

* https://issues.redhat.com/projects/SDN/issues/SDN-5438 [docs] Allow a single `bridge-mapping` to be referenced from multiple different UDNs
* https://issues.redhat.com/browse/OSDOCS-12356
* https://docs.google.com/document/d/1cqDZcw4UPmSTelR95YJM9m1yFssAyR0RY03TPiaDP14/edit?tab=t.0#heading=h.uk9urcbgslco

