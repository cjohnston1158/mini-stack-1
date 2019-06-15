echo ">   Staging Cloudctl Profile ..."
cat <<EOF >/tmp/lxd_profile_cloudctl.yaml
config:
  user.network-config: |
    version: 2
    ethernets:
      eth0:
        dhcp4: true
        dhcp6: false
      eth1:
        dhcp4: false
        dhcp6: false
        addresses: [ ${ministack_SUBNET}.3/24 ]
        gateway4: ${ministack_SUBNET}.1
        nameservers:
          addresses: [ ${ministack_SUBNET}.10 ]
          search: [ maas ]
  user.user-data: |
    #cloud-config
    package_upgrade: true
    packages:
      - jq
      - git
      - vim
      - tree
      - tmux
      - lnav
      - byobu
      - snapd
      - apache2
      - maas-cli
      - squashfuse
      - libvirt-bin
      - python-pip
      - python-openstackclient
      - python-keystoneclient
      - python-cinderclient
      - python-swiftclient
      - python-glanceclient
      - python-novaclient
      - python-nova-adminclient
      - python-neutronclient
    runcmd:
      - [echo, "'CLOUDCTL-DBG: Start RUNCMD'"]
      - [echo, "CLOUDINIT-DBG: runcmd 0.0 - base prep"]
      - [virsh, net-destroy, default]
      - [virsh, net-undefine, default]
      - [apt-get, autoremove, "-y"]
      - [snap, install, juju, "--classic"]
      - [cp, "-f", "/etc/skel/.bashrc", "/root/.bashrc"]
      - ["ssh-import-id", "${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}"]
      - [update-alternatives, "--set", "editor", "/usr/bin/vim.basic"]
      - [echo, "CLOUDINIT-DBG: runcmd 1.0 - user prep: ubuntu"]
      - [su, "-l", "ubuntu", "/bin/bash", "-c", "ssh-keygen -f ~/.ssh/id_rsa -N ''"]
      - [su, "-l", "ubuntu", "/bin/bash", "-c", "'byobu-enable'"]
      - [cp, "-f", "/etc/skel/.bashrc", "/home/ubuntu/.bashrc"]
      - [echo, "CLOUDINIT-DBG: runcmd 2.0 - user prep ${ministack_UNAME}"]
      - [su, "-l", "${ministack_UNAME}", "/bin/bash", "-c", "ssh-keygen -f ~/.ssh/id_rsa -N ''"]
      - [su, "-l", "${ministack_UNAME}", "-c", "/bin/bash -c 'byobu-enable'"]
      - [cp, "-f", "/etc/skel/.bashrc", "/home/${ministack_UNAME}/.bashrc"]
      - [echo, "CLOUDINIT-DBG: runcmd 3.0 - base final"]
      - [chown, "-R", "ubuntu:ubuntu", "/home/ubuntu"]
      - [chown, "-R", "${ministack_UNAME}:${ministack_UNAME}", "/home/${ministack_UNAME}"]
      - [echo, "CLOUDINIT-DBG: runcmd 0.0 - cloud-config runcmd complete ... rebooting"]
      - [reboot]
description: ccio mini-stack cloudctl container profile
devices:
  eth0:
    name: eth0
    nictype: macvlan
    parent: external
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: cloudctl
EOF

# Detect && Purge 'cloudctl' Profile
echo ">   Checking for & Removing Pre-Existing CloudCTL Profile ..."
[[ $(lxc profile show cloudctl 2>&1 1>/dev/null ; echo $?) != 0 ]] || lxc profile delete cloudctl

# Create && Write Profile
lxc profile create cloudctl

echo ">   Loading CloudCTL User Data"
lxc profile edit cloudctl < <(cat /tmp/lxd_profile_cloudctl.yaml)
