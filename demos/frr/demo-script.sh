#!/bin/bash

# git clone https://github.com/paxtonhare/demo-magic.git
source ~/src/demos/demo-magic/demo-magic.sh
TYPE_SPEED=100
PROMPT_TIMEOUT=2
#DEMO_PROMPT="${CYAN}\W${GREEN}➜ ${COLOR_RESET}"
DEMO_PROMPT="${CYAN}\W-frr ${GREEN}$ ${COLOR_RESET}"
DEMO_COMMENT_COLOR=$GREEN
GIT_ROOT=$(git rev-parse --show-toplevel)
DEMO_ROOT=$GIT_ROOT/demos/frr

# https://archive.zhimingwang.org/blog/2015-09-21-zsh-51-and-bracketed-paste.html
#unset zle_bracketed_paste
clear

p "# FRR (Free Range Routing) w BGP (Border Gateway Protocol) Demo"
p "# Let's explore the basic setup and configuration"

p "# 🔍 First, let's look at our demo structure"
pei tree -L 3 $DEMO_ROOT
p

p "# 🔍 Here's our VM configuration with FRR pre-installed"
pei 'bat $DEMO_ROOT/base/scripts/userData'
p

p "# 🔧 Let's create our RHEL VM with FRR"
pei "oc apply -k $DEMO_ROOT/overlays/frr"

p "# ⌛ waiting for VM to come up..."
sleep 60

p "# 💻 Let's check FRR status and configuration"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo systemctl status frr'"

p

p "# 🔍 Let's examine the FRR configuration"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo cat /etc/frr/frr.conf'"

p

p "# 💻 Let's check BGP status using vtysh"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo vtysh -c \"show ip bgp summary\"'"

p

p "# 💻 Let's look at the routing table"
pei "ssh cloud-user@frr.demo-frr.cnv 'sudo vtysh -c \"show ip route\"'"

p

p "# 🎉 That's the basics of FRR!"
 
exit

DEMO_COMMENT_COLOR=$BLUE
p "# 🚿 Cleaning up..."
DEMO_COMMENT_COLOR=$GREEN

pei "oc delete -k overlays/frr"
exit
