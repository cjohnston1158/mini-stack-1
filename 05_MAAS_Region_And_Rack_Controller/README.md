# Part 05 -- MAAS Region And Rack Controller in LXD
###### Install MAAS Region & Rack Controllers in LXD on Open vSwitch Network

-------
Prerequisites:
- [Part 00 Host System Prep]
- [Part 01 Single Port Host OVS Network Config]
- [Part 02 LXD On Open vSwitch Networks]
- [Part 03 Build CloudCTL LXD Bastion]
- [Part 04 LXD Network Gateway]

![CCIO_Hypervisor - KVM-On-Open-vSwitch](web/drawio/MAAS-Region-And-Rack-Ctl-on-OVS-Sandbox.svg)

-------
#### 01. Create maas container profile
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/05_MAAS_Region_And_Rack_Controller/aux/build-lxd-profile-maasctl.sh | bash
````
#### 02. Create 'maasctl' Ubuntu Bionic LXD Container
````sh
lxc launch ubuntu:bionic maasctl -p maasctl
lxc exec maasctl -- tail -f /var/log/cloud-init-output.log
````
  - NOTE: Build time is dependent on hardware & network specs, monitor logs until build is complete
#### 03. Run MAAS Setup
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/05_MAAS_Region_And_Rack_Controller/aux/run-setup-maas.sh | bash
````
#### 04. Write Custom Userdata
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/05_MAAS_Region_And_Rack_Controller/aux/build-maas-curtin-userdata.sh | bash
lxc exec maasctl -- /bin/bash -c "mkdir /root/bak ; cp /etc/maas/preseeds/curtin_userdata /root/bak/"
lxc file push /tmp/curtin_userdata maasctl/etc/maas/preseeds/curtin_userdata
````
#### 05. Login to WebUI && Confirm region and rack controller(s) show healthy
 1. Browse to your maas WebUI @ [http://openwrt-gateway-pub-ip:5240/MAAS](http://{openwrt-gateway-pub-ip}:5240/MAAS)
 2. Click 'skip' through on-screen setup prompts (this was already done via cli)    
 3. Click "Controllers" tab    
 4. Click "maasctl.maas"    
 5. services should all be 'green' excluding dhcp* & ntp*    
  - NOTE: dhcp services are dependent on completion of full image sync. Please wait till image download & sync has finished.

#### 06. Reboot and confirm MAAS WebUI & MAAS Region+Rack controller services are all healthy again
-------
#### OPTIONAL: Add maas support for the 'external' network bridge
````sh
wget -qO- http://${ministack_SUBNET}.3/mini-stack/05_MAAS_Region_And_Rack_Controller/aux/maas-add-external.sh | bash
````
-------
## Next sections
- [Part 06 Install Libvirt/KVM on OVS Networks]
- [Part 07 MAAS Libvirt POD Provider]
- [Part 08 Juju MAAS Cloud Provider]
- [Part 09 Build OpenStack Cloud]
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
