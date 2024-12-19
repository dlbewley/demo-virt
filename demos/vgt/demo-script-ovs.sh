#!/bin/bash

# git clone https://github.com/paxtonhare/demo-magic.git
source ~/src/demos/demo-magic/demo-magic.sh
TYPE_SPEED=100
PROMPT_TIMEOUT=2
#DEMO_PROMPT="${CYAN}\W${GREEN}➜ ${COLOR_RESET}"
DEMO_PROMPT="${CYAN}\W-ovs ${GREEN}$ ${COLOR_RESET}"
DEMO_COMMENT_COLOR=$GREEN
GIT_ROOT=$(git rev-parse --show-toplevel)
DEMO_ROOT=$GIT_ROOT/demos/vgt

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
#unset zle_bracketed_paste
N=hub-v4tbg-cnv-99zmp
clear

p "# here is the NNCP to create OVS bridge called 'br-trunk'"
p "# the NIC receives an 802.1q trunk from its switch"
pei 'bat $DEMO_ROOT/components/br-trunk/ovs-bridge/nncp.yaml'

p

p "# here is the NAD to create a localnet called 'trunk'"
pei 'bat $DEMO_ROOT/components/trunk/ovs-bridge/nad.yaml'

p

p "# here is the NNCP to create that OVN bridge-mapping"
p "# which will map the localnet to the ovs bridge"
pei 'bat $DEMO_ROOT/components/trunk/ovs-bridge/nncp.yaml'

p

p "# here is a kustomization overlay to create the bridge and mapping"
pei "bat $DEMO_ROOT/overlays/ovs-bridge/kustomization.yaml"

p

p "# it uses a base to create the VM using the trunk network attachment"
pei "bat -P $DEMO_ROOT/base/kustomization.yaml"

p

p "# apply the ovs-bridge overlay to create everything including a VM"
pei "oc apply -k $DEMO_ROOT/overlays/ovs-bridge"

p

p "# confirm results of NNCP and NNCE"
pei "oc get nncp ovs-bridge-mapping-trunk"
pei "oc get nnce -l nmstate.io/policy=ovs-bridge-mapping-trunk"

p "# now that the mapping is defined we can test using the 'trunk' NAD"

p "# do it all including spinning up a VM on the trunk network attachement"
pei "oc apply -k $DEMO_ROOT/base"

DEMO_COMMENT_COLOR=$RED
p "# FAIL this is not yet possible with ovn-kubernetes localnet"
p "# https://issues.redhat.com/browse/RFE-6831"

DEMO_COMMENT_COLOR=$GREEN

exit
