net_config () {
ovs-vsctl del-br lxdbr0
ovs-vsctl add-br lxdbr0 \
       --   add-port lxdbr0 eth0 \
       --   add-port lxdbr0 mgmt0 \
       --   set interface mgmt0 type=internal \
       --   set interface mgmt0 mac="02\:13\:88\:ec\:69\:7b"
systemctl restart systemd-networkd.service
netplan apply --debug
}

net_config
