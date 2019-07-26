# Part 00 -- Host System Preparation

#### Review checklist of prerequisites:
  1. You have a fresh install of Ubuntu Server 18.04 LTS on a machine with no critical data or services on it
  2. You are familiar with and able to ssh between machines
  3. You have an ssh key pair, and uploaded the public key to your [Launchpad](https://launchpad.net/) or [Github](https://github.com/) account
  4. Run all prep commands as root
  5. Recommended: Follow these guides using ssh to copy/paste commands as you read along

-------
#### 01. Create CCIO Mini-Stack Profile
```sh
wget https://git.io/fjVUb -qO /tmp/profile && source /tmp/profile
```
#### 02. Update System && Install helper packages
```sh
apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y
apt install --install-recommends -y whois neovim lnav openssh-server ssh-import-id snapd pastebinit linux-generic-hwe-18.04-edge
```
#### 03. Append GRUB Options for Libvirt & Networking Kernel Arguments
```sh
mkdir /etc/default/grub.d 2>/dev/null
```
```sh
cat <<EOF >/etc/default/grub.d/99-libvirt.cfg
# Enable PCI Passthrough + Nested Virtual Machines + Revert NIC Interface Naming
GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} debug intel_iommu=on iommu=pt kvm_intel.nested=1 net.ifnames=0 biosdevname=0 pci=noaer"
EOF
```
```sh
update-grub
```
#### 04. Write eth0 netplan config
```sh
cat <<EOF >/etc/netplan/99-eth0.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
EOF
```
#### 05. Reboot
-------
## OPTIONAL
##### OPT 01. Switch default editor from nano to vim
```sh
update-alternatives --set editor /usr/bin/vim.tiny
```
##### OPT 02. Disable Lid Switch Power/Suspend (if building on a laptop)
```sh
sed -i 's/^#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
```
##### OPT 03. Disable default GUI startup  (DESKTOP OS)
  NOTE: Use command `systemctl start graphical.target` to manually start full GUI environment at will
```sh
systemctl set-default multi-user.target
```
-------
## Next sections
- [Part 01 Single Port Host OVS Network Config]
- [Part 02 LXD On Open vSwitch Networks]
- [Part 03 Build CloudCTL LXD Bastion]
- [Part 04 LXD Network Gateway]
- [Part 05 MAAS Region And Rack Controller]
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
