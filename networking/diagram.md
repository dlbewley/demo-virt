# OpenShift Virtualization Networking Diagrams

## OVS Bridge Localnet Topology Example

This method maps Network Attachment Definitions to an OVS Bridge via a Bridge Mapping. The bridge mapping is constructed by NNCP. The bridge may be the existing default br-ex or a custom bridge, eg. br-vmdata, constructed by NNCP. Packets entering the bridge from ens224 retain their 802.1q tags as they traverse the switch.

An OVS logical switch will be created (`ovn-nbctl ls-list`) with a logical switch port for the bridge and for each of the pod network interfaces (`ovn-nbctl lsp-list vmdata_ovn_localnet_switch`).


The network name as found in the NAD.spec.config.name is used as the selector to identify the appropriate bridge for a given network via the bridge mapping.

The `name` in the config of a Network Attachment Definition defines "a network". Any NADs which grant access to this "network" must be the same. The name of the NAD its self is only consequential when assigning it to an interface via Multus.

<!-- https://dompl.medium.com/produce-great-looking-flowcharts-in-seconds-7f3bea64f2e2 -->
<!-- 
ovncli hub-tq2sk-cnv-qt59g
sh-5.1# ovn-nbctl ls-list
b126a387-8cf2-42be-a214-5a853b8929ec (ext_hub-tq2sk-cnv-qt59g)
0efe6d8d-0ddf-4128-9ca1-a6ecbe77e063 (hub-tq2sk-cnv-qt59g)
014427a8-b291-4b9a-98e6-cb503aca2fca (isolated_ovn_layer2_switch)
282f5c3f-1ec1-426b-949e-6642197b3411 (join)
5343e6cd-34b5-41fc-9f13-2a7590e7efed (transit_switch)
b30b5253-7fe4-46a4-b74f-d21845c773c5 (vlan.1924_ovn_localnet_switch)
4b795783-2692-42d0-be2b-4bb760a16b8d (vlan.1926_ovn_localnet_switch) -->

<!-- ```mermaid
gantt
axisFormat %
todayMarker on
section Node Network Config
    Switch Port : TA, 0, 1d
    NIC Config : TB, after TA, 1d
section Network Attachment 1924
    NAD : TC, after TB, 1d
    NNCP : TD, after TC, 1d
section Network Attachment 1926
    NAD : TE, after TB, 1d
    NNCP : TF, after TE, 1d
``` -->

```mermaid
graph LR;

  switch["Switch fa:fa-grip-vertical"]
  machinenet["fa:fa-network-wired Machine Network<br> 192.168.4.0/24"]
  switch ==> machinenet ==> ens192
  ens192 --> br-ex[["fa:fa-grip-vertical fa:fa-bridge br-ex"]]

  switch[[switch]] ==> T(["fa:fa-tags 802.1q Trunk"]) ==> ens224[ens224]

  subgraph node["CNV Worker"]
    ens192["fa:fa-ethernet ens192"]
    servicenet["fa:fa-network-wired Service Network<br> 172.30.0.0/16"]
    clusternet["fa:fa-network-wired Cluster Network<br> 10.128.0.0/14"]

    br-ex --> servicenet
    br-ex --> clusternet



    subgraph nncp["fa:fa-code NNCP"]
      ens224["fa:fa-ethernet ens224"]
      ens224 --> br-vmdata[["fa:fa-grip-vertical fa:fa-bridge br-vmdata"]]
      BM1924[/"fa:fa-tags bridge mapping\nvlan-1924 to br-vmdata"/] -.-> br-vmdata
      BM1926[/"fa:fa-tags bridge mapping\nvlan-1926 to br-vmdata"/] -.-> br-vmdata

    end

    br-vmdata --> ovs1924[[vlan.1924_ovn_localnet_switch]]
    br-vmdata --> ovs1926[[vlan.1926_ovn_localnet_switch]]


  end
  subgraph nsdefault["Namespace 'default'"]
    subgraph nad["fa:fa-code NAD"]
      ns2-nad-1924[/"fa:fa-code NAD 'vlan-1924'\nlocalnet name 'vlan-1924'"/] -.- BM1924
      ns2-nad-1926[/"fa:fa-code NAD 'vlan-1926'\nlocalnet name 'vlan-1926'"/] -.- BM1926
    end
  end

  subgraph ns1["Namespace 1"]
    subgraph ns1-vm1[fab:fa-linux VM Pod Net]
        nginx-nic["fa:fa-ethernet eth0"]
    end
    clusternet --> nginx-nic

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    ovs1924  --> ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github Dev VM]
        ns2-vm1-nic2["fa:fa-ethernet eth0"]
        ns2-vm1-nic1["fa:fa-ethernet net1"]
    end

    clusternet --> ns2-vm1-nic2

    subgraph ns2-vm2["fa:fa-database DB VM"]
        ns2-vm2-nic2["fa:fa-ethernet net2"]
        ns2-vm2-nic1["fa:fa-ethernet net1"]
    end

    subgraph ns2-vm3["fab:fa-redhat WS VM"]
        ns2-vm3-nic1["fa:fa-ethernet net1"]
    end

    ovs1924 --- ns2-vm2-nic2
    ovs1924 --- ns2-vm1-nic1
    ovs1926 --- ns2-vm3-nic1
    ovs1926 --- ns2-vm2-nic1
  end

  classDef clusterNet fill:#bfb
  class clusternet,nginx-nic,ns2-vm1-nic2 clusterNet

  classDef vlan-1924 fill:#bbf,color:black
  class ens224.1924,BM1924,ns1-nad-1924,ns2-nad-1924,ns1-vm2-nic1,ns1-ws2-1924,ns2-vm1-nic1,ns2-vm2-nic2,ovs1924 vlan-1924

  classDef vlan-1926 fill:#fbb, color:black
  class ens224.1926,BM1926,ns1-nad-1926,ns2-nad-1926,ns2-vm2-nic1,ns2-vm3-nic1,ovs1926 vlan-1926

  classDef bridge color:#9999,file:cyan, color:black
  class br-ex,br-vmdata bridge

  style nad stroke:#f66,stroke-width:2px,color:#9999,file:none,stroke-dasharray: 5 5
  style nncp stroke:#f66,stroke-width:2px,color:#999,stroke-dasharray: 5 5
  style T fill:white,stroke:darkgrey,stroke-width:1px,color:#333,stroke-dasharray: 2 2

  classDef ns1-vm fill:#eff
  class ns1-vm1,ns1-vm2 ns1-vm
  style ns1 fill:Grey

  classDef ns2-vm fill:#cdd
  class ns2-vm1,ns2-vm2,ns2-vm3 ns2-vm
  style ns2 fill:Grey

  style nsdefault fill:#ccc
```


## Linux Bridge VLAN Filtering Example

This method treats the linux bridge as if it were a physical switch. Packets entering the bridge from ens224 retain their 802.1q tags as they traverse the switch.

Veth ports added to the bridge for pods can optionally retain or strip the VLAN tags upon egress from the bridge.

```mermaid
graph LR;

  switch["Switch fa:fa-grip-vertical"]
  machinenet["fa:fa-network-wired Machine Network<br> 192.168.4.0/24"]
  switch --> machinenet --> ens192
  ens192 ==> br-ex[["fa:fa-grip-vertical fa:fa-bridge br-ex"]]
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
