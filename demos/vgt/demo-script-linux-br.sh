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
p "# here is the NNCP to create linux bridge called 'br-trunk'"
p "# the NIC receives an 802.1q trunk from its switch"
pei 'bat $DEMO_ROOT/components/br-trunk/linux-bridge/nncp.yaml'

p

p "# here is the NAD to create a cnv-bridge called 'trunk'"
pei 'bat -H 11 -H 21 $DEMO_ROOT/components/trunk/linux-bridge/nad.yaml'
p "# the vlanId: {} line is key to seeing all VLANs"
p

p "# it uses a base to create the VM using the trunk network attachment"
pei "bat -P $DEMO_ROOT/base/kustomization.yaml"

p

p "# apply the ovs-bridge overlay to create everything including a VM"
pei "oc apply -k $DEMO_ROOT/overlays/linux-bridge"

p

p "# confirm results of NNCP and NNCE"
pei "oc wait nncp/br-trunk --for=condition=Available=True"
pei "oc get nnce -l nmstate.io/policy=br-trunk"

p

p "# now wait for the VM to come up. meanwhile..."
p "# here is the script that tries to setup the VLAN interface "

pei "bat $DEMO_ROOT/base/scripts/netsetup"
sleep 60

p "# check the VM's network interfaces"
pei "ssh cloud-user@rhel-node-1.demo-vgt.cnv nmcli con 2>/dev/null"
pei "ssh cloud-user@rhel-node-1.demo-vgt.cnv ip -br -c -4 a 2>/dev/null"

p

p "# tcpdump should reveal some VLAN tags on the trunk interface"
pei "ssh cloud-user@rhel-node-1.demo-vgt.cnv sudo tcpdump -nni eth1 -e -c5 2>/dev/null |grep vlan"

p "# success!"
 
DEMO_COMMENT_COLOR=$BLUE
p "# Time to clean up"
DEMO_COMMENT_COLOR=$GREEN
p "# deleting an NNCP does not delete created interfaces, change the state to absent"
p "# and remove the NNCP after the change is applied"
p
oc patch -n demo-vgt nncp/br-trunk --type=json \
  -p='[{"op":"replace", "path":"/spec/desiredState/interfaces/1/state", "value": "absent"}]'

oc wait nncp/br-trunk --for=condition=Available=True

oc delete -k overlays/linux-bridge
exit
