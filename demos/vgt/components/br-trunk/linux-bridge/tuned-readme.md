# 4.19 has defaults:
sh-5.1# cat /proc/sys/net/ipv4/conf/default/forwarding
0
sh-5.1# cat /proc/sys/net/ipv4/conf/all/forwarding
0

# 4.18 has defaults:
cat /proc/sys/net/ipv4/conf/default/forwarding
1
cat /proc/sys/net/ipv4/conf/all/forwarding
1


## Applying Tuned with

```
net.ipv4.ip_forward=1
net.ipv4.conf.default.forwarding=0
net.ipv4.conf.all.forwarding=0
```

```yaml
apiVersion: tuned.openshift.io/v1
kind: Tuned
metadata:
  name: ip-forward-linux-bridge
  namespace: openshift-cluster-node-tuning-operator
spec:
  profile:
    - name: ip-forward-linux-bridge
      data: |
        [main]
        summary=Allow IPv4 forwarding globally but only enable it on specified interface

        [sysctl]
        # 4.19 has defaults:
        # sh-5.1# cat /proc/sys/net/ipv4/conf/default/forwarding
        # 0
        # sh-5.1# cat /proc/sys/net/ipv4/conf/all/forwarding
        # 0
        # 4.18 has defaults:
        # cat /proc/sys/net/ipv4/conf/default/forwarding
        # 1
        # cat /proc/sys/net/ipv4/conf/all/forwarding
        # 1
        #
        # Global on; default/all off; turn on only for ens256
        net.ipv4.ip_forward=1
        net.ipv4.conf.default.forwarding=0
        net.ipv4.conf.all.forwarding=0
        # test with this off first
        # net.ipv4.conf.ens256.forwarding=1
  recommend:
    - profile: ip-forward-linux-bridge
      priority: 10
      match:
        - label: machine.openshift.io/cluster-api-machineset
          value: hub-v57jl-cnv
```

* Before

```bash
for node in $(oc get nodes -l machine.openshift.io/cluster-api-machineset=hub-v57jl-cnv -o name); do echo "# $node"; oc debug $node -- grep -H ^ /host/proc/sys/net/ipv4/conf/{ens192,ens224,ens256,all,default}/forwarding 2>/dev/null; done
# node/hub-v57jl-cnv-25fpw
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-7q2rm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-9c5qm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-vtlqc
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:1
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:1
/host/proc/sys/net/ipv4/conf/default/forwarding:1
```

* During
```bash
oc apply -f tuned.yaml
tuned.tuned.openshift.io/ip-forward-linux-bridge created
```

* After

```bash
# node/hub-v57jl-cnv-25fpw
/host/proc/sys/net/ipv4/conf/ens192/forwarding:0
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-7q2rm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:0
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-9c5qm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:0
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-vtlqc
/host/proc/sys/net/ipv4/conf/ens192/forwarding:0
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:0
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
```

And after I deleted the Tuned the forwarding is 1 across the board which is beyond where it started.

```bash
for node in $(oc get nodes -l machine.openshift.io/cluster-api-machineset=hub-v57jl-cnv -o name); do echo "# $node"; oc debug $node -- grep -H ^ /host/proc/sys/net/ipv4/conf/{ens192,ens224,ens256,all,default}/forwarding 2>/dev/null; done
# node/hub-v57jl-cnv-25fpw
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:1
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:1
/host/proc/sys/net/ipv4/conf/default/forwarding:1
# node/hub-v57jl-cnv-7q2rm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:1
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:1
/host/proc/sys/net/ipv4/conf/default/forwarding:1
# node/hub-v57jl-cnv-9c5qm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:1
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:1
/host/proc/sys/net/ipv4/conf/default/forwarding:1
# node/hub-v57jl-cnv-vtlqc
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:1
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:1
```

A reboot fixed that. Back to how it started.


# Test 2

I think I only need to set the nic because forwarding is possible globally as evidenced by the fact it is enabled on ens192.

Here is the tuned.yaml

```yaml
apiVersion: tuned.openshift.io/v1
kind: Tuned
metadata:
  name: ip-forward-linux-bridge
  namespace: openshift-cluster-node-tuning-operator
spec:
  profile:
    - name: ip-forward-linux-bridge
      data: |
        [main]
        summary=Allow IPv4 forwarding globally but only enable it on specified interface

        [sysctl]
        # 4.19 has defaults:
        # sh-5.1# cat /proc/sys/net/ipv4/conf/default/forwarding
        # 0
        # sh-5.1# cat /proc/sys/net/ipv4/conf/all/forwarding
        # 0
        # 4.18 has defaults:
        # cat /proc/sys/net/ipv4/conf/default/forwarding
        # 1
        # cat /proc/sys/net/ipv4/conf/all/forwarding
        # 1
        #
        # Global on; default/all off; turn on only for ens256
        # net.ipv4.ip_forward=1
        # net.ipv4.conf.default.forwarding=0
        # net.ipv4.conf.all.forwarding=0
        # test with this off first
        net.ipv4.conf.ens256.forwarding=1
  recommend:
    - profile: ip-forward-linux-bridge
      priority: 10
      match:
        - label: machine.openshift.io/cluster-api-machineset
          value: hub-v57jl-cnv
```

* After this it works.

```
for node in $(oc get nodes -l machine.openshift.io/cluster-api-machineset=hub-v57jl-cnv -o name); do echo "# $node"; oc debug $node -- grep -H ^ /host/proc/sys/net/ipv4/conf/{ens192,ens224,ens256,all,default}/forwarding 2>/dev/null; done
# node/hub-v57jl-cnv-25fpw
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-7q2rm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-9c5qm
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
# node/hub-v57jl-cnv-vtlqc
/host/proc/sys/net/ipv4/conf/ens192/forwarding:1
/host/proc/sys/net/ipv4/conf/ens224/forwarding:0
/host/proc/sys/net/ipv4/conf/ens256/forwarding:1
/host/proc/sys/net/ipv4/conf/all/forwarding:0
/host/proc/sys/net/ipv4/conf/default/forwarding:0
```