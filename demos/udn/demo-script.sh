DEMO=udn arec 


# setup
export RED='\033[1;31m'
export BLUE='\033[1;36m'
export PURPLE='\033[1;35m'
export ORANGE='\033[0;33m'
export NC='\033[0m' # No Color
N=master-2
# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
unset zle_bracketed_paste
clear

echo "${BLUE}# script to access the 'control plane' of OVN${NC}"
bat `which ovncli`


oc get userdefinednetworks -n demo-udn 

echo "${BLUE}# script to access the 'control plane' of OVN${NC}"
oc get pods -n demo-udn -o wide

#echo "${BLUE}# connect to OVN northbound db pod on $N ${NC}"
#ovncli $N

echo "${BLUE}# list logical switches on $N${NC}"
ovncli $N ovn-nbctl ls-list

echo "${BLUE}# list logical switch ports on our UDN switch on $N ${NC}"
ovncli $N ovn-nbctl lsp-list demo.udn.l2.back_ovn_layer2_switch

echo "${BLUE}# list logical switch ports on $N node switch ${NC}"
ovncli $N ovn-nbctl lsp-list $N

echo "${BLUE}# list logical routers on $N ${NC}"
ovncli $N ovn-nbctl lr-list

echo "${BLUE}# list routes on UDN gateway router on $N ${NC}"
ovncli $N ovn-nbctl lr-route-list GR_demo.udn.l2.back_master-2

echo "${BLUE}# list routes on cluster gateway router on $N ${NC}"
ovncli $N ovn-nbctl lr-route-list GR_master-2

