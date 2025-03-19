#!/bin/bash

# git clone https://github.com/paxtonhare/demo-magic.git
source ~/src/demos/demo-magic/demo-magic.sh
TYPE_SPEED=100
PROMPT_TIMEOUT=2
#DEMO_PROMPT="${CYAN}\W${GREEN}➜ ${COLOR_RESET}"
DEMO_PROMPT="${CYAN}demo-\W ${GREEN}$ ${COLOR_RESET}"
DEMO_COMMENT_COLOR=$GREEN
GIT_ROOT=$(git rev-parse --show-toplevel)
DEMO_ROOT=$GIT_ROOT/demos/frr

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
#unset zle_bracketed_paste
clear

p "# 🌐 Welcome to the FRR (Free Range Routing) Demo!"
p "# 🔄 We'll explore BGP (Border Gateway Protocol) routing in action"

p "# 📂 Let's peek at our demo structure first"
pei tree -L 3 $DEMO_ROOT
p

p "# 🛠️ Here's how we configure our VM with cloud-init"
p "# 📦 It includes FRR installation and initial setup"
pei 'bat -l properties $DEMO_ROOT/base/scripts/userData'
p

p "# 📝 Now let's examine our FRR configuration file which will be placed in a configmap"
p "# 🔍 This shows our BGP routing setup"
pei 'bat -l properties $DEMO_ROOT/base/scripts/frr.conf'
p

p "# 🚀 Time to launch our RHEL VM with FRR on OpenShift"
p "# 🎯 This will create all necessary resources"
pei "oc apply -k $DEMO_ROOT"

p "# ⏳ Waiting for VM to initialize..."
p "#  🎯 This takes about a minute while the VM boots up"
sleep 1

p "# 🔌 Let's verify FRR is running properly"
p "# 🟢 We should see the service status as 'active'"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo systemctl status frr'"
p

p "# 🌍 Time to check our BGP peering status"
p "# 👥 This shows our BGP neighbors and connection state"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo vtysh -c \"show ip bgp summary\"'"
p

p "# 🗺️ Let's examine our routing table"
p "# 🛣️ This shows all known network paths"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo vtysh -c \"show ip route\"'"
p

p "# 🎉 Awesome! We've successfully explored FRR basics!"
p "# 🎓 You've seen how BGP routing works in action"
 
DEMO_COMMENT_COLOR=$BLUE
p "# 🧹 Time to clean up our demo environment"
DEMO_COMMENT_COLOR=$GREEN

p "# 🗑️ Removing all created resources"
# pei "oc delete -k overlays/frr"
exit
