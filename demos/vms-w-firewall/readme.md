= VMs with Firewall Demo

Testing of L2 overlay networks

[components/l2-front](Front Net) will have (../../components/vms/server-left)[Left Server] attached at `10.111.111.1/24`

[components/l2-back](Back Net) will have (../../components/vms/server-right)[Right Server] attached at `10.222.222.2/24`

(../../components/vms/firewall)[Firewall Server] will be attached to both at `10.111.111.254` and `10.222.222.254`

Left and Right servers will have a static route defined allowing them to ping either other through the Firewall

Networking is configured at boot by (scripts/netsetup)[this script].

Currently, most of the VM configuration is applied via inline patches in (kustomization.yaml)[kustomization.yaml]
