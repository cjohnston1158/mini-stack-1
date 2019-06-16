#!/bin/bash
#################################################################################
cat <<EOF >/tmp/iface-default-route-switch.sh
      gateway4: ${ministack_SUBNET}.1
      nameservers:
        search: [maas, mini-stack.maas]
        addresses: [${ministack_SUBNET}.10,8.8.8.8]
EOF
lxc file edit cloudctl/etc/netplan/50-cloud-init.yaml <(/tmp/iface-default-route-switch.sh)
