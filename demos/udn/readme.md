# Test User Defined Networks

Right now just testing with plain containers rather than VMs.

## Quick Deploy 

```bash
oc apply -k .
```

## Detailed Deploy

* Install OCP 4.18 ec3

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
        net-pod[Default<br> 10.0.2.0/24]:::network;
        %% net-pod --(NAT)--> internet %%
    end

    subgraph Networks["User Defined Network"]
        net-right[L2 Back Net<br> 10.222.222.0/24]:::network;
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
* pods can only contact each other over eth1 😕

![../../img/udn-l2-pod-test.png](../../img/udn-l2-pod-test.png)