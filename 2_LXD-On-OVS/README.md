# Part 2 -- LXD On Open vSwitch Network
##### Install and Configure LXD on a default Open vSwitch Network Bridge
NOTE: This will expose container networking on your LAN by default    

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]

![CCIO_Hypervisor - LXD On OpenvSwitch](web/drawio/lxd-on-openvswitch.svg)

-------
#### 01. Install LXD Packages
````sh
apt install -y lxd squashfuse zfsutils-linux btrfs-tools && modprobe zfs
````

#### 02. Initialize LXD
````sh
lxd init
````
###### Example Interactive Init
````sh
root@bionic:~# lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: default
Name of the storage backend to use (btrfs, dir, lvm) [default=btrfs]: dir
Would you like to connect to a MAAS server? (yes/no) [default=no]: no
Would you like to create a new local network bridge? (yes/no) [default=yes]: no
Would you like to configure LXD to use an existing bridge or host interface?(yes/no) [default=no]: yes
Name of the existing bridge or host interface: external
Would you like LXD to be available over the network? (yes/no) [default=no]: yes
Address to bind LXD to (not including port) [default=all]: all
Port to bind LXD to [default=8443]: 8443
Trust password for new clients:
Again:
Would you like stale cached images to be updated automatically? (yes/no) [default=yes] yes
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
````
#### 03. Add your user(s) to the 'lxd' group with the following syntax for each user
Use your non-root host user name (EG: 'ubuntu')
````sh
usermod -aG lxd ${ministack_UNAME}
````
#### 04. Backup the original lxc profile
````sh
lxc profile copy default original
````
#### 05. Add 'lxc' command alias 'ubuntu'/'(your username)' to auto login to containers as user 'ubuntu'
````sh
sed -i 's/aliases: {}/aliases:\n  ubuntu: exec @ARGS@ -- sudo --login --user ubuntu/g' ~/.config/lxc/config.yml
echo "  ${ministack_UNAME}: exec @ARGS@ -- sudo --login --user ${ministack_UNAME}" >> ~/.config/lxc/config.yml
````
#### 06. Add User-Data
````sh
wget https://git.io/fjav6 -qO /tmp/build-profile-lxd-default && source /tmp/build-profile-lxd-default
````
#### 07. Write OVS bridge 'internal' Networkd Configuration
````sh
cat <<EOF >/etc/systemd/network/internal.network                                                    
[Match]
Name=internal

[Network]
DHCP=no
IPv6AcceptRA=no
LinkLocalAddressing=no
EOF
````
#### 08. Write OVS 'internal' bridge port 'mgmt1' netplan config
````sh
cat <<EOF > /etc/netplan/80-mgmt1.yaml
# Configure mgmt1 on 'internal' bridge
# For more configuration examples, see: https://netplan.io/examples
network:
  version: 2
  renderer: networkd
  ethernets:
    mgmt1:
      optional: true
      dhcp4: false
      dhcp6: false
      addresses:
        - ${ministack_SUBNET}.2/24
EOF
````
#### 09. Build Bridge & mgmt1 interface
````sh
ovs-vsctl \
  add-br internal -- \
  add-port internal mgmt1 -- \
  set interface mgmt1 type=internal -- \
  set interface mgmt1 mac="$(echo "$HOSTNAME internal mgmt1" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02\\:\1\\:\2\\:\3\\:\4\\:\5/')"
ovs-vsctl show
#### 09. Reload host network configuration
````sh
systemctl restart systemd-networkd.service && netplan apply --debug
````
#### 10. Test Launch New Container
````sh
lxc launch ubuntu:bionic c01
lxc ${ministack_UNAME} c01
exit
lxc delete --force c01
````
-------
## Next sections
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
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
