# Part 7 -- Build MAAS Cloud Controller
###### Create a Juju Cloud on MAAS & Bootstrap the Juju Controller

-------
## Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]

![CCIO Hypervisor - JujuCTL Cloud Controller](web/drawio/juju_maas_cloud_controller.svg)

-------
#### 00. Acquire MaasCTL MAAS API Key
````sh
export MAASCTL_API_KEY=$(lxc exec maasctl -- maas-region apikey --username=admin)
````

#### 01. Build CloudCTL Profile
````sh
wget -O- https://git.io/fj87W | bash
````

#### 02. Build CloudCtl Container
````sh
lxc launch ubuntu:bionic cloudctl -p cloudctl
lxc exec cloudctl -- tail -f /var/log/cloud-init-output.log
````
  - NOTE: wait for cloud-init to finish configuring the container, this may take some time...

#### 03. Import CloudCtl ssh keys on host
````sh
lxc exec cloudctl -- /bin/bash -c "cat /home/ubuntu/.ssh/id_rsa.pub" >>/root/.ssh/authorized_keys
lxc exec cloudctl -- /bin/bash -c "cat /home/${ccio_SSH_UNAME}/.ssh/id_rsa.pub" >>/root/.ssh/authorized_keys
````

#### 04. Virsh Build MAAS Cloud JujuCtl Node
````sh
wget -O- https://git.io/fj87R | bash
````

#### 05. Import JujuCtl Virsh Node
````sh
lxc exec maasctl -- /bin/bash -c 'login-maas-cli'
lxc exec maasctl -- /bin/bash -c 'wget -O- https://git.io/fj87E | bash'
````

#### 06. Tag JujuCtl Virsh Node
````sh
lxc exec maasctl -- /bin/bash -c 'wget -O- https://git.io/fj87u | bash'
````
  - NOTE: wait for jujuctl.maas node to show as 'ready' in maasctl webui indicating 'comissioning' is complete

#### 07. Check CloudCtl MaasCtl Cloud && Bootstrap JujuCtl Controller Node
````sh
lxc exec cloudctl -- /bin/bash -c 'passwd ${ccio_SSH_UNAME}'
lxc exec cloudctl -- login ${ccio_SSH_UNAME}
juju clouds
juju credentials
juju bootstrap --bootstrap-series=bionic --config bootstrap-timeout=1800 --constraints "tags=jujuctl" maasctl jujuctl
exit
````
  - NOTE: JujuCtl Comissioning may take some time, wait till complete to continue

#### 08. Set Juju WebUI Password
````sh
lxc exec cloudctl -- su -l ${ccio_SSH_UNAME} -c 'yes admin | juju change-user-password admin'
````

#### 09. Find juju WebUI
````sh
lxc exec cloudctl -- su -l ${ccio_SSH_UNAME} -c 'juju gui'
````

-------
## Continue to the next section
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
