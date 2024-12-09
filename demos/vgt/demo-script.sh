#!/bin/bash

# git clone https://github.com/paxtonhare/demo-magic.git
source ~/src/demos/demo-magic/demo-magic.sh
TYPE_SPEED=100
PROMPT_TIMEOUT=2
#DEMO_PROMPT="${CYAN}\W${GREEN}➜ ${COLOR_RESET}"
DEMO_PROMPT="${CYAN}\W ${GREEN}$ ${COLOR_RESET}"
DEMO_COMMENT_COLOR=$GREEN
GIT_ROOT=$(git rev-parse --show-toplevel)

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
#unset zle_bracketed_paste
N=hub-v4tbg-cnv-99zmp
clear

p "# here is the NNCP to create OVS bridge called 'br-vmdata'"
p "# br-vmdata is on a NIC that receives an 802.1q trunk from its switch"
pei 'bat $GIT_ROOT/networking/components/br-vmdata/ovs-bridge/nncp.yaml'

p

p "# here is the NAD to create a localnet called 'trunk' (line 16)"
pei 'bat $GIT_ROOT/networking/components/trunk/ovs-bridge/nad.yaml'

p

p "# after ovs-bridge 'br-vmdata' exists..."
pei 'oc get nncp br-vmdata'
p "# and net-attach-def 'trunk' defining localnet 'trunk' exists..."
pei 'oc get net-attach-def -n default trunk'
p "# we must map the localnet to the ovs bridge"

p

p "# here is the NNCP to create that OVN bridge-mapping"
pei 'bat $GIT_ROOT/networking/components/trunk/ovs-bridge/nncp.yaml'

p

p "# here is a kustomization to do that with a nodeselector and set the bridge name"
pei "bat $GIT_ROOT/demos/vm-w-vlans/kustomization.yaml"

p "# see!"
pei 'oc kustomize $GIT_ROOT/demos/vm-w-vlans/ | kfilt -k NodeNetworkConfigurationPolicy | bat -l yaml'

p "# create the mapping"
pei "oc apply -k $GIT_ROOT/demos/vm-w-vlans/"

p

pei "oc get nncp ovs-bridge-mapping-trunk"
pei "oc get nnce -l nmstate.io/policy=ovs-bridge-mapping-trunk"

p "# now that the mapping is defined we can test useing the 'trunk' NAD"

p

DEMO_COMMENT_COLOR=$RED
p "# FAIL this is not yet possible with ovn-kubernetes localnet"
p "# https://issues.redhat.com/browse/RFE-6831"

DEMO_COMMENT_COLOR=$GREEN

exit
