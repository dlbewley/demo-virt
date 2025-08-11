#!/bin/bash
# process VLANs from file to create NAD and NNCP from OpenShift Template

BRIDGE=br-vmdata
TMPDIR=$(mktemp -d)
# TEMPLATE=template-nad-ovs-br-localnet-vlan.yaml
TEMPLATE=template-nad-physnet-localnet-vlan.yaml
VLAN_FILE=vlans.txt

# read VLAN IDs and optional names from file
awk '/^[0-9]+/ {print $1 "|" substr($0, length($1)+2)}' $VLAN_FILE \
    | while IFS='|' read -r vlan_id vlan_name; do
    if [[ -n "$vlan_id" ]]; then
        description="${vlan_name:-VLAN-$vlan_id}"
        oc process \
            -f $TEMPLATE \
            -p VLAN="$vlan_id" \
            -p MTU="1500" \
            -p DESCRIPTION="Attachment to $description VLAN $vlan_id through OVS bridge $BRIDGE" \
            -o yaml | yq '.items[0]' > "$TMPDIR/nad-$vlan_id.yaml"
        echo "$TMPDIR/nad-$vlan_id.yaml $description"
    fi
done
