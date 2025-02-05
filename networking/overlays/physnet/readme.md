
https://ovn-kubernetes.io/features/multiple-networks/multi-homing/?t#sharing-the-same-physical-network-mapping

Instead of adding a OVN bridge mapping via NNCP per NAD add a physicalNetworkName to each NAD and then create a single mapping for that common string.
