# Part 5 -- MAAS Region And Rack Server on OVS Sandbox
###### Install MAAS Region & Rack Controllers on Open vSwitch Network

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]

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
wget -qO-
http://${ministack_SUBNET}.3/mini-stack/05_MAAS_Region_And_Rack_Controller/aux/run-setup-maas.sh | bash
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
