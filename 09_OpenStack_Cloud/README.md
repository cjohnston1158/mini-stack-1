# Part 09 -- Build OpenStack Cloud
###### Provision OpenStack Deployment Requirements

Prerequisites:
- [Part 00 Host System Prep]
- [Part 01 Single Port Host OVS Network Config]
- [Part 02 LXD On Open vSwitch Networks]
- [Part 03 Build CloudCTL LXD Bastion]
- [Part 04 LXD Network Gateway]
- [Part 05 MAAS Region And Rack Controller]
- [Part 06 Install Libvirt/KVM on OVS Networks]
- [Part 07 MAAS Libvirt POD Provider]
- [Part 08 Juju MAAS Cloud Provider]

![CCIO Hypervisor - OpenStack Prep](web/drawio/OpenStack-Prep.svg)

-------
#### 00. Stage Virt-Install VM Standup Script (on host)
```
wget -qO /tmp/virt-inst-stack-nodes http://${ministack_SUBNET}.3/mini-stack/09_OpenStack_Cloud/aux/virt-inst-stack-nodes.sh
```
  - NOTE: Defaults set in script hardware profile section should be adjusted as required in /tmp/virt-inst-stack-nodes
#### 01. Run Virt-Install VM Standup Script (on host)
```
source /tmp/virt-inst-stack-nodes
```

#### 02. Discover new KVM VIrtual Machines via PODS Refresh  (on host)
```
lxc exec maasctl -- maas-nodes-discover
```

#### 03. Tag new mini-stack nodes (on host)
```
lxc exec maasctl -- /bin/bash -c "wget -qO- http://${ministack_SUBNET}.3/mini-stack/09_OpenStack_Cloud/aux/maas-tag-nodes | bash"
```
#### 05. Add Juju Machines (on cloudctl)
```sh
lxc ${ministack_UNAME} cloudctl
for n in 01 02 03; do juju add-machine --constraints tags=mini-stack; done
```
#### 06. Deploy OpenStack from Juju Bundle YAML File (on cloudctl)
```sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/09_OpenStack_Cloud/aux/build-stein-ccio-openstack-juju-bundle.sh | bash
juju deploy /tmp/stein-ccio-openstack-bundle.yaml --map-machines=existing --verbose --debug
```
#### 07. Monitor Deploy (on cloudctl)
```sh
watch -c juju status --color
juju debug-log
```
#### 07. Find Horizon Dashboard IP && Login to OpenStack Horizon WebUI
```sh
clear; juju status openstack-dashboard | grep -E "openstack-dashboard" | grep "${ministack_SUBNET}"
```
  - NOTE: Default Credentials [admin:admin]
#### 07. Click on "admin" user menu drop down in top right
#### 00. Click on "OpenStack RC File" to download your admin-openrc.sh credentials
#### 00. In CloudCtl Terminal Load admin-openrc.sh
```sh
source ~/Downloads/admin-openrc.sh
```
#### 00. Test OS Cli
```sh
openstack hypervisor list
```
#### 00. Add External Provider Network
```sh
openstack network create --enable --external --no-default --provider-network-type flat --provider-physical-network physnet1 ext_net
openstack subnet create --allocation-pool start=${ministack_SUBNET}.40,end=${ministack_SUBNET}.49 --subnet-range ${ministack_SUBNET}.0/24 --no-dhcp --gateway ${ministack_SUBNET}.1 --ip-version
4 --network ext_net ext_net_subnet
```
#### 00. Enable SSH Globally
```sh
openstack security group rule create default --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 --egress
openstack security group rule create default --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 --ingress
```
#### 00. Enable SSH Globally
```sh
openstack security group rule create default --protocol icmp --egress
openstack security group rule create default --protocol icmp --ingress
```
#### 00. Create OS Flavor Types
```sh
openstack flavor create --public --ram 2048 --disk 8 --vcpus 2 --swap 0 m2.2small
openstack flavor create --public --ram 4096 --disk 32 --vcpus 2 --swap 0 m2.4med
openstack flavor create --public --ram 4096 --disk 32 --vcpus 4 --swap 0 m4.4med
```
#### 00. Create Ubuntu Bionic Image
```sh
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img -P ~/Downloads/
openstack image create --public --disk-format raw --container-format bare --file ~/Downloads/bionic-server-cloudimg-amd64.img bionic-cloud-image
```
#### 00. Create OS Key Pair
```sh
openstack keypair create --public-key ~/.ssh/id_rsa.pub default
```
#### 00. Create Internal Router & Network
```sh
openstack network create --share --enable --internal --mtu 1458 int_net
openstack router create --enable edge
openstack subnet create --dhcp --gateway 172.0.0.1 --dns-nameserver ${ministack_SUBNET}.10 --dns-nameserver 8.8.8.8 --subnet-range 172.0.0.0/24 --allocation-pool start=172.0.0.100,end=172.0.0.254 --network int_net int_subnet
openstack router add subnet edge int_subnet
openstack router set --external-gateway ext_net edge
```
#### 00. Launch Instance
```sh
openstack server create --flavor m2.2small --security-group $(openstack security group list -f value | sed -n 2p | awk '{print $1}') --image bionic-cloud-image --nic net-id=$(openstack network list -f value | awk '/int_net/{print $1}') --key-name default t01
```
#### 00. Attach Floating IP $
```sh
openstack floating ip create ext_net
openstack floating ip list
openstack server list
openstack server add floating ip t01 10.10.0.43
```

----
## Next sections
- [Part 10 Build Kubernetes Cloud]

<!-- Markdown link & img dfn's -->
[Part 00 Host System Prep]: ../00_Host_System_Prep
[Part 01 Single Port Host OVS Network Config]: ../01_Single_Port_Host_OpenVSwitch_Config
[Part 02 LXD On Open vSwitch Networks]: ../02_LXD_On_OVS
[Part 03 Build CloudCTL LXD Bastion]: ../03_Cloud_Controller_Bastion
[Part 04 LXD Network Gateway]: ../04_LXD_Network_Gateway
[Part 05 MAAS Region And Rack Controller]: ../05_MAAS_Region_And_Rack_Controller
[Part 06 Install Libvirt/KVM on OVS Networks]: ../06_Libvirt_On_Open_vSwitch
[Part 07 MAAS Libvirt POD Provider]: ../07_MAAS_Libvirt_Pod_Provider
[Part 08 Juju MAAS Cloud Provider]: ../08_Juju_MaaS_Cloud_Configuration
[Part 09 Build OpenStack Cloud]: ../09_OpenStack_Cloud
[Part 10 Build Kubernetes Cloud]: ../10_Kubernetes_Cloud
