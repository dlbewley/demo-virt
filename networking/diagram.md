# Networking Diagram

See <https://access.redhat.com/solutions/6972064> and <https://developers.redhat.com/blog/2017/09/14/vlan-filter-support-on-bridge#without_vlan_filtering> and 

## Bridge Filter Example
This method treats the linux bridge as if it were a physical switch with all the packets tagged as they traverse the switch and selectively untagged upon egress to an interface.


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
      ens224 --> br-data["fa:fa-bridge br-data"]

    end
  end

  subgraph ns1["Namespace 1"]
    subgraph ns1-vm1[fab:fa-linux VM Pod Net]
        nginx-nic["fa:fa-ethernet eth0"]
    end
    clusternet ----> nginx-nic
    {%% nginx-nic --> nat((NAT)) --> inet("fa:fa-cloud Inet") %%}

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    br-1924 -.- ns1-nad-1924[/"fa:fa-code NAD 'dev-net'"/] --> ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github DevB VM]
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

    br-data -.- ns2-nad-1924[/"fa:fa-code NAD 'vlan-1924'"/] --- ns2-vm1-nic1
                ns2-nad-1924                                 --- ns2-vm2-nic2
    br-data -.- ns2-nad-1927[/"fa:fa-code NAD 'vlan-1927'"/] --- ns2-vm2-nic1
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

## Older Example

This example peels VLANs off the NIC and defines a single bridge per VLAN. This may have a positive impact on efficiency of traffic between hosts on this same VLAN as they will avoid tagging and untagging. It is a more complex configuration.

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
    {%% nginx-nic --> nat((NAT)) --> inet("fa:fa-cloud Inet") %%}

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    br-1924 -.- ns1-nad-1924[/"fa:fa-code NAD 'dev-net'"/] --> ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github DevB VM]
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
