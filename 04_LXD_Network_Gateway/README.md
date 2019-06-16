# Part 3 -- LXD Gateway & Firewall for Open vSwitch Network Isolation
###### Create a sandboxed network environment with OpenVSwitch and an LXD Gateway using the [Unofficial OpenWRT LXD Project](https://github.com/containercraft/openwrt-lxd)

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](web/drawio/lxd-gateway.svg)

-------
#### 01. Add the BCIO Remote LXD Image Repo
````sh
lxc remote add bcio https://images.braincraft.io --public --accept-certificate
````
#### 02. Create OpenWRT LXD Profile
````sh
lxc profile copy original openwrt
lxc profile set openwrt security.privileged true
lxc profile device set openwrt eth0 nictype bridged
lxc profile device set openwrt eth0 parent external
lxc profile device add openwrt eth1 nic nictype=bridged parent=internal
````
#### 03. Launch Gateway
````sh
lxc launch bcio:openwrt gateway -p openwrt
lxc exec gateway -- /bin/bash -c "sed -i 's/192.168.1/${ministack_SUBNET}/g' /etc/config/network"
lxc restart gateway
````
  - NOTE: use `watch -c lxc list` to monitor and ensure you get both internal & external IP's on the gateway
#### 04. Apply CCIO Configuration + http squid cache proxy
````sh
wget -qO- http://10.9.8.3/mini-stack/4_LXD_Network_Gateway/aux/bin/run-gateway-config | bash
````
  - WARNING: DO NOT LEAVE EXTERNAL WEBUI ENABLED ON UNTRUSTED NETWORKS
#### 05. Move Default route & DNS from mgmt0 to mgmt1 iface
````sh
cat <<EOF >> /etc/netplan/80-mgmt1.yaml
      gateway4: ${ministack_SUBNET}.1
      nameservers:
        search: [maas, mini-stack.maas]
        addresses: [${ministack_SUBNET}.10,8.8.8.8]
EOF
````
````sh
sed -i -e :a -e '$d;N;2,5ba' -e 'P;D' /etc/netplan/80-mgmt0.yaml
````
#### 06. Reload host network configuration
````sh
systemctl restart systemd-networkd.service && netplan apply --debug
````
#### 07. Copy LXD 'default' profile to 'external'
````sh
lxc profile copy default external
````
#### 08. Set LXD 'default' profile to use the 'internal' network
````sh
lxc profile device set default eth0 parent internal
````
#### 09. Reboot Host
````sh
reboot
````
#### 10. Test OpenWRT WebUI Login on 'external' IP Address    
  - CREDENTIALS: [USER:PASS] [root:admin] -- [http://gateway_external_ip_addr:8080/](http://gateway_external_ip_addr:8080/)

-------
#### OPTIONAL: Enable your new 'internal' network on a physical port. (EG: eth1)
````sh
export internal_NIC="eth1"
````
````sh
cat <<EOF > /etc/systemd/network/${internal_NIC}.network                                                    
[Match]
Name=${internal_NIC}

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````
````sh
ovs-vsctl add-port internal ${internal_NIC}
systemctl restart systemd-networkd.service
````

-------
## Next sections
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Prep]

<!-- Markdown link & img dfn's -->
[Part 0 Host System Prep]: ../0_Host_System_Prep
[Part 1 Single Port Host OVS Network]: ../1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part 2 LXD On Open vSwitch Network]: ../2_LXD-On-OVS
[Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: ../3_LXD_Network_Gateway
[Part 4 KVM On Open vSwitch]: ../4_KVM_On_Open_vSwitch
[Part 5 MAAS Region And Rack Server on OVS Sandbox]: ../5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part 6 MAAS Connect POD on KVM Provider]: ../6_MAAS-Connect_POD_KVM-Provider
[Part 7 Juju MAAS Cloud]: ../7_Juju_MAAS_Cloud
[Part 8 OpenStack Prep]: ../8_OpenStack_Deploy
