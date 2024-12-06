# Test User Defined Networks

Testing [User Defined Networking](https://docs.openshift.com/container-platform/4.17/networking/multiple_networks/understanding-user-defined-network.html)

https://ovn-kubernetes.io/api-reference/userdefinednetwork-api-spec/

Right now just testing with plain containers rather than VMs.

## Quick Deploy 

```bash
oc apply -k .
```

## Detailed Deploy

* Install OCP [4.18 ec4](https://mirror.openshift.com/pub/openshift-v4/clients/ocp-dev-preview/4.18.0-ec.4/)

* Enable UDN with [this job](../../networking/components/enable-udn/)

* Create a [Layer2 UDN](../../networking/components/l2-back/udn/udn.yaml) in demo-udn namespace

```yaml
apiVersion: k8s.ovn.org/v1
kind: UserDefinedNetwork
metadata:
  name: l2-back
spec:
  topology: Layer2
  layer2:
    ipamLifecycle: Persistent
    role: Primary
    subnets:
      - 10.222.222.0/24
```

* Create 2 [pods](pod.yaml) in demo-udn namespace

* View logs on the pods

* `oc rsh` to the client pod and curl the httpd pod on port 8080

## Diagram

```mermaid
graph TD;
    classDef interface fill:#ffcc00,stroke:#333,stroke-width:2px;
    classDef network fill:#0ddd,stroke:#333,stroke-width:2px;
    classDef neighbor fill:#ffeb99,stroke:#333,stroke-width:2px;

    subgraph Cluster ["Primary Cluster Network"]
        net-pod[Default<br> 10.128.0.0/23]:::network;
        %% net-pod --(NAT)--> internet %%
    end

    subgraph Networks["User Defined Network"]
        net-right[L2 Back Net<br> 10.222.222.0/24]:::network;
    end

    subgraph Networks["Masquerade Network"]
        net-masquerade[Masquerade Subnet<br> 169.254.0.0/17]:::network;
    end

    subgraph Httpd
        server-left-eth0[eth0<br>10.128.0.145/23]:::interface;
        server-left-eth0 --> net-pod
        server-left-eth1[eth1<br>10.222.222.7/24]:::interface;
        server-left-eth1 ==> net-right
    end

    subgraph Client
        server-right-eth0[eth0<br>10.128.0.144/24]:::interface;
        server-right-eth0 --> net-pod
        server-right-eth1[eth1<br>10.222.222.6/24]:::interface;
        server-right-eth1 ==> net-right
    end
```

## Observations

* the pods have 2 interfaces automatically. "look ma, no multus!"
* eth0 is on the cluster network 10.128.0.0/14
* eth1 is given an IP on the range associated with the Layer 2 UDN
* pods can only contact each other over eth1
* a net-attach-def is automatically created 

[![asciicast demo](https://asciinema.org/a/689869.svg)](https://asciinema.org/a/689869)

[![asciicast ovn](https://asciinema.org/a/690175.svg)](https://asciinema.org/a/690175)

![../../img/udn-l2-pod-test.png](../../img/udn-l2-pod-test.png)


_Shout out to  [@v1k0d3n](https://github.com/v1k0d3n) for walking me through getting started._
