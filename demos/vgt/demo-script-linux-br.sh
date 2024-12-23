#!/bin/bash

# git clone https://github.com/paxtonhare/demo-magic.git
source ~/src/demos/demo-magic/demo-magic.sh
TYPE_SPEED=100
PROMPT_TIMEOUT=2
#DEMO_PROMPT="${CYAN}\W${GREEN}➜ ${COLOR_RESET}"
DEMO_PROMPT="${CYAN}\W-lbr ${GREEN}$ ${COLOR_RESET}"
DEMO_COMMENT_COLOR=$GREEN
GIT_ROOT=$(git rev-parse --show-toplevel)
DEMO_ROOT=$GIT_ROOT/demos/vgt

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
#unset zle_bracketed_paste
clear

p "# all the things"
pei tree -L 3 $DEMO_ROOT
p
p "# 🔍 here is the NNCP to create linux bridge called 'br-trunk'"
p "# the NIC receives an 802.1q trunk from its switch"
pei 'bat $DEMO_ROOT/components/br-trunk/linux-bridge/nncp.yaml'

p

p "# 🔍 here is the NAD to create a cnv-bridge called 'trunk'"
pei 'bat -H 11 -H 21 $DEMO_ROOT/components/trunk/linux-bridge/nad.yaml'
p "# the vlanId: {} line is key to passing all VLAN tags into the bridge"

p

p "# 🔧 apply the linux-bridge overlay to create the trunk, network attachment, and a VM"
pei "oc apply -k $DEMO_ROOT/overlays/linux-bridge"

p

p "# 🔍 confirm results of NNCP and NNCE"
pei "oc wait nncp/br-trunk --for=condition=Available=True"
pei "oc get nnce -l nmstate.io/policy=br-trunk"

p

p "# ⌛ wait for the VM to come up..."
p "# meanwhile here is the script to setup the VLAN interface on the VM"

pei "bat -l bash $DEMO_ROOT/base/scripts/netsetup"

sleep 90

p "# 💻 login to the VM and take a look at the network interfaces"
pei "ssh cloud-user@rhel-node-1.demo-vgt.cnv"

p

p "# 🎉 SUCCESS!"
 
DEMO_COMMENT_COLOR=$BLUE
p "# 🚿 time to clean up"
DEMO_COMMENT_COLOR=$GREEN

p "# deleting an NNCP does not delete created interfaces, so change the state to absent"
p "# and remove the NNCP after the change is applied"
pei 'oc patch -n demo-vgt nncp/br-trunk --type=json -p="[{\"op\":\"replace\",\"path\":\"/spec/desiredState/interfaces/1/state\",\"value\":\"absent\"}]" '
p

pei "oc wait nncp/br-trunk --for=condition=Available=True"

p

pei "oc delete -k overlays/linux-bridge"
exit
