#!/bin/bash

# git clone https://github.com/paxtonhare/demo-magic.git
source ~/src/demos/demo-magic/demo-magic.sh
TYPE_SPEED=100
PROMPT_TIMEOUT=2
#DEMO_PROMPT="${CYAN}\W${GREEN}➜ ${COLOR_RESET}"
DEMO_PROMPT="${CYAN}\W ${GREEN}$ ${COLOR_RESET}"
DEMO_COMMENT_COLOR=$GREEN

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
#unset zle_bracketed_paste
N=master-2
clear

p "# here is a script to access the 'control plane' of OVN"
pei 'bat `which ovncli`'

p
p '# view existing UserDefinedNetworks'
pei 'oc get userdefinednetworks -n demo-udn'
pei "oc get userdefinednetworks -n demo-udn l2-back -o yaml | yq .spec"

p '# view the example httpd and client pods'
pe 'oc get -n demo-udn pods -o wide'

p '# view IP in udn-client pod'
pei "oc rsh -n demo-udn udn-client ip -c -br -4 a 2>/dev/null"

p "# use above script to list logical switches on $N"
p "# notice that namespace 'demo-udn' became 'demo.udn' and netork 'l2-back' became 'l2.back'"
pei "ovncli $N ovn-nbctl ls-list"

p "# list logical switch ports on our UDN switch on $N"
p "# notice the pods"
pei "ovncli $N ovn-nbctl lsp-list demo.udn.l2.back_ovn_layer2_switch"

p
p "# list logical switch ports on $N node switch"
pei "ovncli $N ovn-nbctl lsp-list $N"

p
p "# list logical routers on $N"
pei "ovncli $N ovn-nbctl lr-list"

p "# list routes on UDN gateway router on $N"
pei "ovncli $N ovn-nbctl lr-route-list GR_demo.udn.l2.back_master-2"

p "# list routes on cluster gateway router on $N"
pei "ovncli $N ovn-nbctl lr-route-list GR_master-2"

