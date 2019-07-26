# Part 06 -- Install Libvirt/KVM on OVS Networks
###### Install and Configure Libvirt / KVM / QEMU on Open vSwitch 'Default' Network

-------
Prerequisites:
- [Part 00 Host System Prep]
- [Part 01 Single Port Host OVS Network Config]
- [Part 02 LXD On Open vSwitch Networks]
- [Part 03 Build CloudCTL LXD Bastion]
- [Part 04 LXD Network Gateway]
- [Part 05 MAAS Region And Rack Controller]


![CCIO_Hypervisor - LXD On OpenvSwitch](web/drawio/kvm-on-open-vswitch.svg)

-------
#### 01. Install Packages
````sh
apt install -y qemu qemu-kvm qemu-utils libvirt-bin libvirt0 virtinst
````
#### 02. Backup & Destroy default NAT Network
````sh
mkdir ~/bak 2>/dev/null ; virsh net-dumpxml default | tee ~/bak/virsh-net-default-bak.xml
virsh net-destroy default && virsh net-undefine default
````
#### 03. Write xml config for 'default' network on 'internal' bridge
````sh
cat <<EOF >/tmp/virsh-net-default-on-internal.json
<network>
  <name>default</name>
  <forward mode='bridge'/>
  <bridge name='internal' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
#### 04. Write xml config 'internal' network on 'internal' bridge
````sh
cat <<EOF >/tmp/virsh-net-internal-on-internal.json
<network>
  <name>internal</name>
  <forward mode='bridge'/>
  <bridge name='internal' />
  <virtualport type='openvswitch'/>
</network>
EOF

````
#### 05. Write xml config 'external' network on 'external' bridge
````sh
cat <<EOF >/tmp/virsh-net-external-on-external.json
<network>
  <name>external</name>
  <forward mode='bridge'/>
  <bridge name='external' />
  <virtualport type='openvswitch'/>
</network>
EOF
````
#### 06. Create networks from config files
````sh
for json in virsh-net-default-on-internal.json virsh-net-internal-on-internal.json virsh-net-external-on-external.json; do virsh net-define /tmp/${json}; done
for virshet in external default internal; do virsh net-start ${virshet}; virsh net-autostart ${virshet}; done
````
#### 07. Verify virsh network:
````sh
sudo virsh net-list --all
````
````sh
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes
 internal             active     yes           yes
 external             active     yes           yes
````

-------
## Next sections
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
