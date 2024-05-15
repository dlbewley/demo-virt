# OpenShift Virtualization Networking Diagrams

## OVS Bridge Localnet Topology Example

This method maps Network Attachment Definitions to an OVS Bridge via a Bridge Mapping. The bridge mapping is constructed by NNCP. The bridge may be the existing default br-ex or a custom bridge, eg. br-vmdata, constructed by NNCP. Packets entering the bridge from ens224 retain their 802.1q tags as they traverse the switch.

An OVS logical switch will be created (`ovn-nbctl ls-list`) with a logical switch port for the bridge and for each of the pod network interfaces (`ovn-nbctl lsp-list vmdata_ovn_localnet_switch`).


The network name as found in the NAD.spec.config.name is used as the selector to identify the appropriate bridge for a given network via the bridge mapping.

The `name` in the config of a Network Attachment Definition defines "a network". Any NADs which grant access to this "network" must be the same.

```mermaid
graph LR;

  switch["Switch fa:fa-grip-vertical"]
  machinenet["fa:fa-network-wired Machine Network<br> 192.168.4.0/24"]
  switch --> machinenet --> ens192
  switch ==> T(["fa:fa-tags 802.1q Trunk"]) ==> ens224[ens224]

  subgraph node["CNV Worker"]
    ens192["fa:fa-ethernet ens192"]
    servicenet["fa:fa-network-wired Service Network<br> 172.30.0.0/16"]
    clusternet["fa:fa-network-wired Cluster Network<br> 10.128.0.0/14"]

    ens192 --> servicenet
    ens192 --> clusternet

    subgraph nncp["fa:fa-code NNCP"]
      ens224["fa:fa-ethernet ens224"]
      ens224 ==> br-vmdata[["fa:fa-grip-vertical fa:fa-bridge br-vmdata"]]
      br-vmdata --> BM1924(["fa:fa-tags bridge mapping"])
      br-vmdata --> BM1926(["fa:fa-tags bridge mapping"])

      note["NOTE: Bridge-mappings are entries of a single list."]
    end

    BM1924 --> vmdata_ovn_localnet_switch
    BM1926 --> vmdata_ovn_localnet_switch

  end

  subgraph ns1["Namespace 1"]
    subgraph ns1-vm1[fab:fa-linux VM Pod Net]
        nginx-nic["fa:fa-ethernet eth0"]
    end
    clusternet ----> nginx-nic

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    vmdata_ovn_localnet_switch  -.- ns1-nad-1924[/"fa:fa-code NAD 'dev-net'"/] --> ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github Dev VM]
        ns2-vm1-nic1["fa:fa-ethernet net1"]
        ns2-vm1-nic2["fa:fa-ethernet eth0"]
    end

    clusternet --> ns2-vm1-nic2

    subgraph ns2-vm2["fa:fa-database DB VM"]
        ns2-vm2-nic1["fa:fa-ethernet net1"]
        ns2-vm2-nic2["fa:fa-ethernet net2"]
    end

    subgraph ns2-vm3["fab:fa-redhat WS VM"]
        ns2-vm3-nic1["fa:fa-ethernet net1"]
    end

    vmdata_ovn_localnet_switch -.- ns2-nad-1924[/"fa:fa-code NAD 'vlan-1924'"/] --- ns2-vm1-nic1
                ns2-nad-1924                                   --- ns2-vm2-nic2
    vmdata_ovn_localnet_switch -.- ns2-nad-1927[/"fa:fa-code NAD 'vlan-1927'"/] --- ns2-vm2-nic1
                ns2-nad-1927                                   --- ns2-vm3-nic1
  end

  classDef clusterNet fill:#bfb
  class clusternet,nginx-nic,ns2-vm1-nic2 clusterNet

  classDef vlan-1924 fill:#bbf
  class ens224.1924,br-1924,ns1-nad-1924,ns2-nad-1924,ns1-vm2-nic1,ns1-ws2-1924,ns2-vm1-nic1,ns2-vm2-nic2 vlan-1924

  classDef vlan-1927 fill:#fbb
  class ens224.1927,br-1927,ns1-nad-1927,ns2-nad-1927,ns2-vm2-nic1,ns2-vm3-nic1 vlan-1927

  style nncp stroke:#f66,stroke-width:2px,color:#999,stroke-dasharray: 5 5
  style T fill:white,stroke:darkgrey,stroke-width:1px,color:#333,stroke-dasharray: 2 2

  classDef ns1-vm fill:#eff
  class ns1-vm1,ns1-vm2 ns1-vm
  style ns1 fill:#eee

  classDef ns2-vm fill:#cdd
  class ns2-vm1,ns2-vm2,ns2-vm3 ns2-vm
  style ns2 fill:#ccc
```


## Linux Bridge VLAN Filtering Example

This method treats the linux bridge as if it were a physical switch. Packets entering the bridge from ens224 retain their 802.1q tags as they traverse the switch.

Veth ports added to the bridge for pods can optionally retain or strip the VLAN tags upon egress from the bridge.

```mermaid
graph LR;

  switch["Switch fa:fa-grip-vertical"]
  machinenet["fa:fa-network-wired Machine Network<br> 192.168.4.0/24"]
  switch --> machinenet --> ens192
  switch ==> T(["fa:fa-tags 802.1q Trunk"]) ==> ens224[ens224]

  subgraph node["CNV Worker"]
    ens192["fa:fa-ethernet ens192"]
    servicenet["fa:fa-network-wired Service Network<br> 172.30.0.0/16"]
    clusternet["fa:fa-network-wired Cluster Network<br> 10.128.0.0/14"]

    ens192 --> servicenet
    ens192 --> clusternet

    subgraph nncp["fa:fa-code NNCP"]
      ens224["fa:fa-ethernet ens224"]
      ens224 ==> br-vmdata[["fa:fa-grip-vertical fa:fa-bridge br-vmdata"]]
    end
  end

  subgraph ns1["Namespace 1"]
    subgraph ns1-vm1[fab:fa-linux VM Pod Net]
        nginx-nic["fa:fa-ethernet eth0"]
    end
    clusternet ----> nginx-nic

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    br-vmdata -.- ns1-nad-1924[/"fa:fa-code NAD 'dev-net'"/] --> ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github Dev VM]
        ns2-vm1-nic1["fa:fa-ethernet net1"]
        ns2-vm1-nic2["fa:fa-ethernet eth0"]
    end

    clusternet --> ns2-vm1-nic2

    subgraph ns2-vm2["fa:fa-database DB VM"]
        ns2-vm2-nic1["fa:fa-ethernet net1"]
        ns2-vm2-nic2["fa:fa-ethernet net2"]
    end

    subgraph ns2-vm3["fab:fa-redhat WS VM"]
        ns2-vm3-nic1["fa:fa-ethernet net1"]
    end

    br-vmdata -.- ns2-nad-1924[/"fa:fa-code NAD 'vlan-1924'"/] --- ns2-vm1-nic1
                ns2-nad-1924                                   --- ns2-vm2-nic2
    br-vmdata -.- ns2-nad-1927[/"fa:fa-code NAD 'vlan-1927'"/] --- ns2-vm2-nic1
                ns2-nad-1927                                   --- ns2-vm3-nic1
  end

  classDef clusterNet fill:#bfb
  class clusternet,nginx-nic,ns2-vm1-nic2 clusterNet

  classDef vlan-1924 fill:#bbf
  class ens224.1924,br-1924,ns1-nad-1924,ns2-nad-1924,ns1-vm2-nic1,ns1-ws2-1924,ns2-vm1-nic1,ns2-vm2-nic2 vlan-1924

  classDef vlan-1927 fill:#fbb
  class ens224.1927,br-1927,ns1-nad-1927,ns2-nad-1927,ns2-vm2-nic1,ns2-vm3-nic1 vlan-1927

  style nncp stroke:#f66,stroke-width:2px,color:#999,stroke-dasharray: 5 5
  style T fill:white,stroke:darkgrey,stroke-width:1px,color:#333,stroke-dasharray: 2 2

  classDef ns1-vm fill:#eff
  class ns1-vm1,ns1-vm2 ns1-vm
  style ns1 fill:#eee

  classDef ns2-vm fill:#cdd
  class ns2-vm1,ns2-vm2,ns2-vm3 ns2-vm
  style ns2 fill:#ccc
```

## VLAN Interface Example

This example peels VLANs off the NIC to define an interface per VLAN. Then a bridge is creatd for each VLAN. Traffic entering this bridge is already untagged.

This may have a positive impact on efficiency of traffic between pods on this same VLAN as they will avoid tagging and untagging. It is a more complex configuration.

```mermaid
graph LR;

  switch["Switch fa:fa-grip-vertical"]
  machinenet["fa:fa-network-wired Machine Network<br> 192.168.4.0/24"]
  switch --> machinenet --> ens192
  switch ==> T(["fa:fa-tags 802.1q Trunk"]) ==> ens224[ens224]

  subgraph node["CNV Worker"]
    ens192["fa:fa-ethernet ens192"]
    servicenet["fa:fa-network-wired Service Network<br> 172.30.0.0/16"]
    clusternet["fa:fa-network-wired Cluster Network<br> 10.128.0.0/14"]

    ens192 --> servicenet
    ens192 --> clusternet

    subgraph nncp["fa:fa-code NNCP"]
      ens224["fa:fa-ethernet ens224"]
      ens224 --> ens224.1924
      ens224 --> ens224.1927

      subgraph vlan1924["fa:fa-tag VLAN 1924<br> 192.168.4.0/24"]
        ens224.1924("fa:fa-tag ens224.1924")
        ens224.1924 --- br-1924[["br-1924 fa:fa-grip-vertical"]]
      end

      subgraph vlan1927["fa:fa-tag VLAN 1927<br> 192.168.7.0/24"]
        ens224.1927("fa:fa-tag ens224.1927")
        ens224.1927 --- br-1927[["br-1927 fa:fa-grip-vertical"]]
      end
    end
  end

  subgraph ns1["Namespace 1"]
    subgraph ns1-vm1[fab:fa-linux VM Pod Net]
        nginx-nic["fa:fa-ethernet eth0"]
    end
    clusternet ----> nginx-nic

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    br-1924 -.- ns1-nad-1924[/"fa:fa-code NAD 'dev-net'"/] --> ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github Dev VM]
        ns2-vm1-nic1["fa:fa-ethernet net1"]
        ns2-vm1-nic2["fa:fa-ethernet eth0"]
    end

    clusternet --> ns2-vm1-nic2

    subgraph ns2-vm2["fa:fa-database DB VM"]
        ns2-vm2-nic1["fa:fa-ethernet net1"]
        ns2-vm2-nic2["fa:fa-ethernet net2"]
    end

    subgraph ns2-vm3["fab:fa-redhat WS VM"]
        ns2-vm3-nic1["fa:fa-ethernet net1"]
    end

    br-1924 -.- ns2-nad-1924[/"fa:fa-code NAD 'vlan-1924'"/] --- ns2-vm1-nic1
                ns2-nad-1924                                 --- ns2-vm2-nic2
    br-1927 -.- ns2-nad-1927[/"fa:fa-code NAD 'vlan-1927'"/] --- ns2-vm2-nic1
                ns2-nad-1927                                 --- ns2-vm3-nic1
  end

  classDef clusterNet fill:#bfb
  class clusternet,nginx-nic,ns2-vm1-nic2 clusterNet

  classDef vlan-1924 fill:#bbf
  class ens224.1924,br-1924,ns1-nad-1924,ns2-nad-1924,ns1-vm2-nic1,ns1-ws2-1924,ns2-vm1-nic1,ns2-vm2-nic2 vlan-1924
  style vlan1924 fill:#99f

  classDef vlan-1927 fill:#fbb
  class ens224.1927,br-1927,ns1-nad-1927,ns2-nad-1927,ns2-vm2-nic1,ns2-vm3-nic1 vlan-1927
  style vlan1927 fill:#f99

  style nncp stroke:#f66,stroke-width:2px,color:#999,stroke-dasharray: 5 5
  style T fill:white,stroke:darkgrey,stroke-width:1px,color:#333,stroke-dasharray: 2 2

  classDef ns1-vm fill:#eff
  class ns1-vm1,ns1-vm2 ns1-vm
  style ns1 fill:#eee

  classDef ns2-vm fill:#cdd
  class ns2-vm1,ns2-vm2,ns2-vm3 ns2-vm
  style ns2 fill:#ccc
```

## Examples

[Network components](../demos/components/networks)

## References

* <https://kubevirt.io/2023/OVN-kubernetes-secondary-networks-localnet.html>
* <https://access.redhat.com/solutions/6972064>
* <https://developers.redhat.com/blog/2017/09/14/vlan-filter-support-on-bridge#without_vlan_filtering>
