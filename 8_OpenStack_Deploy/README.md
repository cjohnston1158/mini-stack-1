# Part 8 -- OpenStack Prep
###### Provision OpenStack Deployment Requirements

Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]

![CCIO Hypervisor - OpenStack Prep](web/drawio/OpenStack-Prep.svg)

-------
#### 00. Virt-Install new vm's (on host)
```
wget -qO /tmp/virt-inst-stack-nodes http://${ministack_SUBNET}.3/mini-stack/8_OpenStack_Deploy/aux/virt-inst-stack-nodes.sh
```
  - NOTE: Defaults set in script hardware profile section should be adjusted as required in /tmp/virt-inst-stack-nodes
#### 01. Virt-Install new vm's (on host)
```
source /tmp/virt-inst-stack-nodes
```

#### 02. Discover new KVM VIrtual Machines via PODS Refresh  (on host)
```
lxc exec maasctl -- import-nodes-maas
```

#### 03. Tag new mini-stack nodes (on host)
```
lxc exec maasctl -- /bin/bash -c "wget -qO- http://${ministack_SUBNET}.3/mini-stack/8_OpenStack_Deploy/aux/maas-tag-nodes | bash"
```
#### 00. Enroll Juju MAAS Cloud Provider
```sh
wget -qO- http://10.9.8.3/mini-stack/8_OpenStack_Deploy/aux/add-maas-cloud-provider.sh | bash
lxc exec cloudctl -- /bin/bash -c 'source /tmp/juju-enroll-maas-provider.sh'
```
#### 04. Create Juju Model (on cloudctl)
```sh
juju add-model mini-stack
```
#### 05. Add Juju Machines (on cloudctl)
```sh
for n in 01 02 03; do juju add-machine --constraints tags=mini-stack; done
```
#### 06. Deploy OpenStack from Juju Bundle YAML File (on cloudctl)
```sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/8_OpenStack_Deploy/aux/stein-ccio-openstack-juju-bundle.yaml | bash
juju deploy /tmp/mini-stack-openstack-bundle.yaml --map-machines=existing --verbose --debug
```
#### 07. Monitor Deploy (on cloudctl)
```sh
watch -c juju status --color
juju debug-log
```

- [Part 9 Kubernetes Deploy]
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
[Part 9 Kubernetes Deploy]: ../9_Kubernetes_Deploy
