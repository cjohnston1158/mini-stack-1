# Part 08 -- Juju MAAS Cloud Provider
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Prep]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

-------
#### 01. Enroll MAAS as Juju Cloud Provider
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/8_OpenStack_Deploy/aux/add-maas-cloud-provider.sh | bash
lxc exec cloudctl -- su -l ${ministack_uname} -c 'source /tmp/juju-enroll-maas-provider.sh'
````
#### 02. Test Cloud & Credentials
````sh
lxc exec cloudctl -- su -l ${ministack_USER} -c "juju clouds"
lxc exec cloudctl -- su -l ${ministack_USER} -c "juju credentials"
````
#### 04. Import JujuCTL as MaaS Node
````sh
lxc exec maasctl -- login-maas-cli
lxc exec maasctl -- maas-nodes-discover
````
#### 03. Build 'jujuctl' libvirt juju controller vm
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/08_Juju_MaaS_Cloud_Configuration/aux/virt-inst-jujuctl-node.sh | bash
````
#### 05. Tag JujuCtl Libvirt VM
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/08_Juju_MaaS_Cloud_Configuration/aux/maas-tag-nodes.sh | bash
````
#### 05. Bootstrap Juju Controller
````sh
lxc exec cloudctl -- su -l ${ministack_USER} -c 'juju bootstrap --bootstrap-series=bionic --config bootstrap-timeout=1800 --constraints "tags=jujuctl" maasctl jujuctl'
````
#### 06. Create Juju Model (on cloudctl)
````sh
lxc exec cloudctl -- su -l ${ministack_USER} -c 'juju add-model mini-stack'
````
-------
## Next sections

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
