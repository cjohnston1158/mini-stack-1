cat <<EOF >/tmp/lxd_profile_cloudctl.yaml
config:
  user.network-config: |
    version: 2
    ethernets:
      eth0:
        dhcp4: false
        dhcp6: false
        addresses: [ ${ministack_SUBNET}.3/24 ]
        gateway4: ${ministack_SUBNET}.1
        nameservers:
          addresses: [ ${ministack_SUBNET}.10 ]
          search: [ maas ]
  user.user-data: |
    #cloud-config
    ssh_import_id: ${ccio_SSH_UNAME}
    package_upgrade: true
    packages:
      - jq
      - vim
      - tree
      - tmux
      - byobu
      - lnav
      - snapd
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
    users:
      - name: ubuntu
        shell: /bin/bash
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        ssh_import_id: ${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}
      - name: ${ccio_SSH_UNAME}
        shell: /bin/bash
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        ssh_import_id: ${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}
    write_files:
      - content: |
          clouds:
            maasctl:
              type: maas
              auth-types: [oauth1]
              endpoint: http://${ministack_SUBNET}.10:5240/MAAS
        path: /tmp/juju/maasctl.yaml
      - content: |
          credentials:
            maasctl:
              admin:
                auth-type: oauth1
                maas-oauth: ${MAASCTL_API_KEY}
        path: /tmp/juju/credentials-maasctl.yaml
    runcmd:
      - ["ssh-import-id", "${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}"]
      - [echo, "'CLOUDCTL-DBG: Start RUNCMD'"]
      - [cp, "-f", "/etc/skel/.bashrc", "/root/.bashrc"]
      - [snap, install, juju, "--classic"]
      - [apt-get, autoremove, "-y"]
      - [virsh, net-destroy, default]
      - [virsh, net-undefine, default]
      - [update-alternatives, "--set", "editor", "/usr/bin/vim.basic"]
      - [wget, "-O", "/usr/bin/login-maas-cli", "https://git.io/fj8QV"]
      - [chmod, "+x", "/usr/bin/login-maas-cli"]
      - [chmod, "777", "-R", "/tmp/juju"]
      - [chown, "-R", "ubuntu:ubuntu", "/home/ubuntu"]
      - [chown, "-R", "${ccio_SSH_UNAME}:${ccio_SSH_UNAME}", "/home/${ccio_SSH_UNAME}"]
      - [echo, "CLOUDINIT-DBG: runcmd 1.0 - snap env cfg"]
      - ["/bin/bash", "-c", 'sed -i "s/\/usr\/games:\/usr\/local\/games/\/snap\/bin/g" /etc/environment']
      - [echo, "CLOUDINIT-DBG: runcmd 2.0 - user prep ubuntu"]
      - [cp, "-f", "/etc/skel/.bashrc", "/home/ubuntu/.bashrc"]
      - [chown, "-R", "ubuntu:ubuntu", "/home/ubuntu"]
      - [su, "-l", "ubuntu", "/bin/bash", "-c", "ssh-keygen -f ~/.ssh/id_rsa -N ''"]
      - [su, "-l", "ubuntu", "/bin/bash", "-c", "'byobu-enable'"]
      - [su, "-l", "ubuntu", "-c", 'login-maas-cli']
      - [echo, "CLOUDINIT-DBG: runcmd 2.2 - juju add-cloud"]
      - [su, "-l", "ubuntu", "-c", "/bin/bash -c 'juju clouds'"]
      - [su, "-l", "ubuntu", "-c", "/bin/bash -c 'juju add-cloud maasctl /tmp/juju/maasctl.yaml'"]
      - [echo, "CLOUDINIT-DBG: runcmd 2.3 - juju add-credential"]
      - [su, "-l", "ubuntu", "-c", "/bin/bash -c 'juju add-credential maasctl -f /tmp/juju/credentials-maasctl.yaml'"]
      - [chown, "-R", "ubuntu:ubuntu", "/home/ubuntu"]
      - [echo, "CLOUDINIT-DBG: runcmd 3.0 - user prep ${ccio_SSH_UNAME}"]
      - [cp, "-f", "/etc/skel/.bashrc", "/home/${ccio_SSH_UNAME}/.bashrc"]
      - [chown, "-R", "${ccio_SSH_UNAME}:${ccio_SSH_UNAME}", "/home/${ccio_SSH_UNAME}"]
      - [su, "-l", "${ccio_SSH_UNAME}", "/bin/bash", "-c", "ssh-keygen -f ~/.ssh/id_rsa -N ''"]
      - [su, "-l", "${ccio_SSH_UNAME}", "-c", "/bin/bash -c 'byobu-enable'"]
      - [su, "-l", "${ccio_SSH_UNAME}", "-c", 'login-maas-cli']
      - [echo, "CLOUDINIT-DBG: runcmd 3.1 - juju add-cloud"]
      - [su, "-l", "${ccio_SSH_UNAME}", "-c", "/bin/bash -c 'juju clouds'"]
      - [su, "-l", "${ccio_SSH_UNAME}", "-c", "/bin/bash -c 'juju add-cloud maasctl /tmp/juju/maasctl.yaml'"]
      - [echo, "CLOUDINIT-DBG: runcmd 3.2 - juju add-credential"]
      - [su, "-l", "${ccio_SSH_UNAME}", "-c", "/bin/bash -c 'juju add-credential maasctl -f /tmp/juju/credentials-maasctl.yaml'"]
      - [chown, "-R", "${ccio_SSH_UNAME}:${ccio_SSH_UNAME}", "/home/${ccio_SSH_UNAME}"]
      - [echo, "CLOUDINIT-DBG: runcmd 0.0 - cloud-config runcmd complete"]
description: ccio mini-stack cloudctl container profile
devices:
  eth0:
    name: eth0
    nictype: macvlan
    parent: internal
    type: nic
  root:
    path: /
    pool: default
    type: disk
name: cloudctl
EOF

# Detect && Purge 'cloudctl' Profile
[[ $(lxc profile list | grep cloudctl ; echo $?) == 0 ]] || lxc profile delete cloudctl

# Create && Write Profile
lxc profile create cloudctl
lxc profile edit cloudctl < <(cat /tmp/lxd_profile_cloudctl.yaml)
