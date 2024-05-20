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
    clusternet --- nginx-nic

    subgraph ns1-vm2[fab:fa-windows WS VM]
        ns1-vm2-nic1["fa:fa-ethernet net1"]
    end
    ovs1924  --- ns1-vm2-nic1
  end

  subgraph ns2["Namespace 2"]
    subgraph ns2-vm1[fab:fa-github Dev VM]
        ns2-vm1-nic2["fa:fa-ethernet eth0"]
        ns2-vm1-nic1["fa:fa-ethernet net1"]
    end

    clusternet --- ns2-vm1-nic2

    subgraph ns2-vm2["fa:fa-database DB VM"]
        ns2-vm2-nic1["fa:fa-ethernet net1"]
        ns2-vm2-nic2["fa:fa-ethernet net2"]
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

## More OVN Spelunking

Trying to visualize the OVN components on a node

```
osh-5.1# ovn-nbctl lr-list
65edf48e-8e56-4cbb-a55d-54ca2b96cb04 (GR_hub-tq2sk-cnv-xcxw2) # <-- routing off the cluster (gatway)
99aba237-a6ed-4a91-9b5d-eaf9dcc4878c (ovn_cluster_router) # <-- routing within the cluster

sh-5.1# ovn-nbctl ls-list
d77c4a1a-d128-44f8-8698-3236384917f1 (ext_hub-tq2sk-cnv-xcxw2) # <-- br-ex and GR
d4222ecf-7a0d-47be-9cd0-cd14e9e3eba9 (hub-tq2sk-cnv-xcxw2)
a0c4ae72-db54-4ac0-a4c0-dd1f7a65855b (join) #
238fbbad-b6a3-474b-9944-6c0f99c5191b (transit_switch)
8a4631c6-f1fa-4eec-aa7c-00f88e85f439 (vlan.1924_ovn_localnet_switch) # guess
5047e67e-d8b6-483f-8718-c38468205e24 (vlan.1926_ovn_localnet_switch) # guess

sh-5.1# ovn-nbctl lsp-list ext_hub-tq2sk-cnv-xcxw2
3007e1e2-0d26-46da-a5a5-b2d5c97dfc77 (br-ex_hub-tq2sk-cnv-xcxw2)
0ddee1da-4102-4f54-935a-e96fb994d147 (etor-GR_hub-tq2sk-cnv-xcxw2)

sh-5.1# ovn-nbctl lrp-list ovn_cluster_router
553af3a3-4663-445a-a1a1-5bbd86219a82 (rtoj-ovn_cluster_router)
0ab8b4a0-2250-4252-a7d9-ea8405cfe921 (rtos-hub-tq2sk-cnv-xcxw2)
d51c8aa7-84be-40cf-876b-8174d35852d0 (rtots-hub-tq2sk-cnv-xcxw2)

sh-5.1# ovn-nbctl show ovn_cluster_router
router 99aba237-a6ed-4a91-9b5d-eaf9dcc4878c (ovn_cluster_router)
    port rtos-hub-tq2sk-cnv-xcxw2
        mac: "0a:58:0a:82:06:01"
        networks: ["10.130.6.1/23"]
        gateway chassis: [f57f0c4e-5d93-4639-a016-7cea61281c04]
    port rtoj-ovn_cluster_router
        mac: "0a:58:64:40:00:01"
        networks: ["100.64.0.1/16"]
    port rtots-hub-tq2sk-cnv-xcxw2
        mac: "0a:58:64:58:00:10"
        networks: ["100.88.0.16/16"]

sh-5.1# ovn-nbctl lrp-list GR_hub-tq2sk-cnv-xcxw2
c06389bb-e92f-499e-8c86-4b64e711ac43 (rtoe-GR_hub-tq2sk-cnv-xcxw2)
6c5ac19f-56af-4ac0-9b03-21cf14081434 (rtoj-GR_hub-tq2sk-cnv-xcxw2)

sh-5.1# ovn-nbctl show GR_hub-tq2sk-cnv-xcxw2
router 65edf48e-8e56-4cbb-a55d-54ca2b96cb04 (GR_hub-tq2sk-cnv-xcxw2)
    port rtoj-GR_hub-tq2sk-cnv-xcxw2
        mac: "0a:58:64:40:00:10"
        networks: ["100.64.0.16/16"]
    port rtoe-GR_hub-tq2sk-cnv-xcxw2
        mac: "00:50:56:b4:76:06"
        networks: ["192.168.4.45/24"]
    nat 00380db1-95ad-4a34-b1db-ff134af85a34
        external ip: "192.168.4.45"
        logical ip: "10.130.6.97"
        type: "snat"
        ... many more nat objects ...
```


```mermaid
graph LR;

subgraph Node
  hostname["Key:\nHOST = hub-tq2sk-cnv-xcxw2"]


  nic

  subgraph ext_hub-tq2sk-cnv-xcxw2["External Switch"]
    sw-ext[[ext_$HOST\n br-ex]]
  end

  sw-ext --> nic

  subgraph join["Join Switch"]
    sw-join[[join]]
  end

  subgraph GR_$HOST["Gateway Router"]
    rt-gw{"GR_$HOST"}
    rt-gw -- lrp:rtoj-GR_$HOST --> sw-join
    rt-gw -- lrp:rtoe-GR_$HOST --> sw-ext
  end

  subgraph transit["Transit Switch"]
    sw-transit[[transit_switch]]
    sw-transit -. tunnels .- master1
    sw-transit -.- master2
    sw-transit -.- master3
    sw-transit -.- worker1
  end

  subgraph sw-rtos-$HOST["Local Switch "]
    sw-local[["sw-rtos-$HOST\n10.130.6.1/23"]]
    sw-local --> pod1
    sw-local --> pod2
    sw-local --> pod3
  end

  subgraph ovn_cluster_router["Cluster Router"]
    rt-cluster{"ovn_cluster_router"}
    rt-cluster -- lrp:rtos-$HOST\n 10.64.0.1/16 --> sw-local
    rt-cluster -- lrp:rtots-$HOST\n 100.88.0.16/16 --> sw-transit
    rt-cluster -- lrp:rtoj-ovn_cluster_router --> sw-join
  end

  end
  nic ==> ToR


  classDef key fill:#ddd, color:black, stroke:black, stroke-width:2
  class hostname key

  classDef nodes fill:#fefefe, stroke:black, stroke-width:4
  class Node nodes

  classDef switch fill:#eff
  class sw-join,sw-transit,sw-local,sw-ext switch

  classDef router fill:#fef
  class rt-gw,rt-cluster router

  classDef routers fill:#fde
  class ovn_cluster_router,GR_$HOST routers

  style ext_hub-tq2sk-cnv-xcxw2 fill:#eef
  style transit fill:#efe
  style join fill:#fde
  style sw-rtos-$HOST fill:#fee

  classDef key fill:#ddd, color:black, stroke:black, stroke-width:2
  class hostname key

  classDef switch fill:#eff
  class sw-join,sw-transit,sw-local,sw-ext switch

  linkStyle default stroke:purple
  linkStyle 0,2,13 stroke:blue
  linkStyle 1,12 stroke:red
  linkStyle 3,4,5,6 stroke:green
  linkStyle 7,8,9,10 stroke:orange
  linkStyle 11 stroke:green

```

```
# ovncli
sh-5.1# ovn-nbctl lsp-list vlan.1924_ovn_localnet_switch
2bda361c-109e-49f8-986e-ef0156a55233 (default.vlan.1924_demo-virt_virt-launcher-rhel-node-1-mjktg)
3816e460-4cce-4335-8fde-dd4c35174b24 (vlan.1924_ovn_localnet_port)

# ssh
[root@hub-tq2sk-cnv-k9wjv ~]# ovs-vsctl show
9ba7b144-6826-4070-8173-a5d721290de0
    Bridge br-vmdata
        Port patch-vlan.1924_ovn_localnet_port-to-br-int
            Interface patch-vlan.1924_ovn_localnet_port-to-br-int
                type: patch
                options: {peer=patch-br-int-to-vlan.1924_ovn_localnet_port}
        Port ens224
            Interface ens224
                type: system
    Bridge br-int
        fail_mode: secure
        datapath_type: system
        Port f322e89f76b98ed
            Interface f322e89f76b98ed
        Port "62009a31c5ab00d"
            Interface "62009a31c5ab00d"
        Port ovn-977c70-0
            Interface ovn-977c70-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.102"}
        Port ovn-71747d-0
            Interface ovn-71747d-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.89"}
        Port "80cbd3e96532f08"
            Interface "80cbd3e96532f08"
        Port cc1f771e8a675cd
            Interface cc1f771e8a675cd
        Port "30481d3db2effed"
            Interface "30481d3db2effed"
        Port "6e3d9e21a693e86"
            Interface "6e3d9e21a693e86"
        Port ovn-f57f0c-0
            Interface ovn-f57f0c-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.45"}
        Port "3c85cc3280c75ce"
            Interface "3c85cc3280c75ce"
        Port d5414d0c94db9d1
            Interface d5414d0c94db9d1
        Port "206ffdd73b5b3a5"
            Interface "206ffdd73b5b3a5"
            Interface "206ffdd73b5b3a5"
        Port "76f353d59f64277"
            Interface "76f353d59f64277"
        Port ovn-881f13-0
            Interface ovn-881f13-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.181"}
        Port br-int
            Interface br-int
                type: internal
        Port ovn-86ab51-0
            Interface ovn-86ab51-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.82"}
        Port ovn-02c2eb-0
            Interface ovn-02c2eb-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.163"}
        Port ovn-05aff4-0
            Interface ovn-05aff4-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.68"}
        Port patch-br-int-to-br-ex_hub-tq2sk-cnv-k9wjv
            Interface patch-br-int-to-br-ex_hub-tq2sk-cnv-k9wjv
                type: patch
                options: {peer=patch-br-ex_hub-tq2sk-cnv-k9wjv-to-br-int}
        Port ovn-7f6616-0
            Interface ovn-7f6616-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.77"}
        Port "40c29fe163e8a4a"
            Interface "40c29fe163e8a4a"
        Port abfe226c6929180
            Interface abfe226c6929180
        Port "2ba29cf8e5bbe67"
            Interface "2ba29cf8e5bbe67"
        Port "511f63e8260de97"
            Interface "511f63e8260de97"
        Port "1ab671dbe37d093"
            Interface "1ab671dbe37d093"
        Port "50b89a888543926"
            Interface "50b89a888543926"
        Port "511f63e8260de_3"
            Interface "511f63e8260de_3"
        Port ovn-k8s-mp0
            Interface ovn-k8s-mp0
                type: internal
        Port d073b63988d5f91
            Interface d073b63988d5f91
        Port "09e0bc834df0d0c"
            Interface "09e0bc834df0d0c"
        Port f43fa51a1518fb2
            Interface f43fa51a1518fb2
        Port ovn-801d28-0
            Interface ovn-801d28-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.168"}
        Port "3aa5973e98ffb82"
            Interface "3aa5973e98ffb82"
        Port "2ebee70a5e9fa2b"
            Interface "2ebee70a5e9fa2b"
        Port c5df87045760c2e
            Interface c5df87045760c2e
        Port e087a462a9e90eb
            Interface e087a462a9e90eb
        Port ovn-543c74-0
            Interface ovn-543c74-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.161"}
        Port patch-br-int-to-vlan.1924_ovn_localnet_port
            Interface patch-br-int-to-vlan.1924_ovn_localnet_port
                type: patch
                options: {peer=patch-vlan.1924_ovn_localnet_port-to-br-int}
        Port "8a914a3ad25dc5e"
            Interface "8a914a3ad25dc5e"
        Port "33283e081f080b9"
            Interface "33283e081f080b9"
        Port "53fba22e053ba42"
            Interface "53fba22e053ba42"
        Port ovn-03cb5c-0
            Interface ovn-03cb5c-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.188"}
        Port ovn-8f754c-0
            Interface ovn-8f754c-0
                type: geneve
                options: {csum="true", key=flow, remote_ip="192.168.4.80"}
        Port a9a944fa882f3ce
            Interface a9a944fa882f3ce
        Port ab72476eec145b9
            Interface ab72476eec145b9
    Bridge br-ex
        Port ens192
            Interface ens192
                type: system
        Port br-ex
            Interface br-ex
                type: internal
        Port patch-br-ex_hub-tq2sk-cnv-k9wjv-to-br-int
            Interface patch-br-ex_hub-tq2sk-cnv-k9wjv-to-br-int
                type: patch
                options: {peer=patch-br-int-to-br-ex_hub-tq2sk-cnv-k9wjv}
    ovs_version: "3.1.5"      

```

**DO NOT TRUST THIS DIAGRAM, WIP**

```mermaid
graph LR;

subgraph Node
  hostname["Key:\nHOST = hub-tq2sk-cnv-xcxw2"]


  nic-ens192[ens192]
  nic-ens224[ens224]

  subgraph ext_hub-tq2sk-cnv-xcxw2["External Switch"]
    sw-ext[[ext_$HOST\n br-ex]]
  end

  sw-ext --> nic-ens192

  subgraph join["Join Switch"]
    sw-join[[join]]
  end

  subgraph br-internal["Internal Bridge"]
    br-int[[br-int]]
  end

  br-vmdata --> nic-ens224

  subgraph bridge-vmdata["VM Data Bridge"]
    br-vmdata[[br-vmdata]]
    br-vmdata -- patch-vlan.1924_ovn_localnet_port-to-br-int --> br-int
  end


  subgraph GR_$HOST["Gateway Router"]
    rt-gw{"GR_$HOST"}
    rt-gw -- lrp:rtoj-GR_$HOST --> sw-join
    rt-gw -- lrp:rtoe-GR_$HOST --> sw-ext
  end

  subgraph transit["Transit Switch"]
    sw-transit[[transit_switch]]
    sw-transit -. tunnels .- master1
    sw-transit -.- master2
    sw-transit -.- master3
    sw-transit -.- worker1
  end

  subgraph sw-rtos-$HOST["Local Switch "]
    sw-local[["sw-rtos-$HOST\n10.130.6.1/23"]]
    sw-local --> pod1
    sw-local --> pod2
    sw-local --> pod3
  end

  subgraph ovn_cluster_router["Cluster Router"]
    rt-cluster{"ovn_cluster_router"}
    rt-cluster -- lrp:rtos-$HOST\n 10.64.0.1/16 --> sw-local
    rt-cluster -- lrp:rtots-$HOST\n 100.88.0.16/16 --> sw-transit
    rt-cluster -- lrp:rtoj-ovn_cluster_router --> sw-join
  end

  end
  nic-ens192 ==> ToR
  nic-ens224 ==> ToR

  classDef nodes fill:#fefefe, stroke:black, stroke-width:4
  class Node nodes

  classDef key fill:#ddd, color:black, stroke:black, stroke-width:2
  class hostname key

  classDef switch fill:#eff
  class sw-join,sw-transit,sw-local,sw-ext switch

  classDef router fill:#fef
  class rt-gw,rt-cluster router

  linkStyle default stroke:purple
  linkStyle 0,2,13 stroke:blue
  linkStyle 1,12 stroke:red
  linkStyle 3,4,5,6 stroke:green
  linkStyle 7,8,9,10 stroke:orange
  linkStyle 11 stroke:green

  classDef routers fill:#fde
  class ovn_cluster_router,GR_$HOST routers

  style ext_hub-tq2sk-cnv-xcxw2 fill:#eef
  style transit fill:#efe
  style join fill:#fde
  style sw-rtos-$HOST fill:#fee


```

  <!-- subgraph vlan-1924["Localnet Switch 1924"]
      sw-1924[["vlan.1924_ovn_localnet_switch"]]
      sw-1924 -- vm
      rt-cluster -- lrp:?? -- sw-1924
  end -->

## Examples

[Network components](../demos/components/networks)

## References

* <https://kubevirt.io/2023/OVN-kubernetes-secondary-networks-localnet.html>
* <https://access.redhat.com/solutions/6972064>
* <https://developers.redhat.com/blog/2017/09/14/vlan-filter-support-on-bridge#without_vlan_filtering>

```

## Examples

[Network components](../demos/components/networks)

## References

* <https://kubevirt.io/2023/OVN-kubernetes-secondary-networks-localnet.html>
* <https://access.redhat.com/solutions/6972064>
* <https://developers.redhat.com/blog/2017/09/14/vlan-filter-support-on-bridge#without_vlan_filtering>
