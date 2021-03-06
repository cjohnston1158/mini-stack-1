﻿#!/bin/bash
source /etc/ccio/mini-stack/profile

write_yaml () {
cat <<EOFEOF >/tmp/stein-ccio-openstack-bundle.yaml
series: bionic
variables:
  data-port: br-ex:ens4
  expected-mon-count: 3
  expected-osd-count: 3
  mysql-connections: 2000
  openstack-origin: 'cloud:bionic-stein'
  osd-devices: '/dev/vdb /dev/vdc'
  worker-multiplier: 0.25
  internal: internal
machines:
  '0':
    series: bionic
    constraints: arch=amd64 cpu-cores=4 mem=4086 tags=mini-stack
  '1':
    series: bionic
    constraints: arch=amd64 cpu-cores=4 mem=4086  tags=mini-stack
  '2':
    series: bionic
    constraints: arch=amd64 cpu-cores=4 mem=4086 tags=mini-stack
services:
  ceph-osd:
    charm: 'cs:ceph-osd-284'
    series: bionic
    options:
      source: 'cloud:bionic-stein'
      osd-devices: '/dev/vdb /dev/vdc'
      autotune: true
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '1000'
      gui-y: '500'
    num_units: 3
    to:
      - '0'
      - '1'
      - '2'
  neutron-gateway:
    charm: 'cs:neutron-gateway-262'
    options:
      openstack-origin: 'cloud:bionic-stein'
      bridge-mappings: 'physnet1:br-ex'
      data-port: 'br-ex:ens4'
      dns-servers: "${ministack_SUBNET}.10,10.0.0.1,8.8.8.8"
      enable-isolated-metadata: true
      instance-mtu: 1500
      worker-multiplier: 0.25
      verbose: true
      debug: true
    annotations:
      gui-x: '0'
      gui-y: '0'
    num_units: 1
    to:
      - '0'
    bindings:
      ? ''
      : internal
  nova-compute:
    charm: 'cs:nova-compute-300'
    options:
      openstack-origin: 'cloud:bionic-stein'
      config-flags: default_ephemeral_format=ext4
      migration-auth-type: ssh
      enable-live-migration: true
      live-migration-permit-post-copy: true
      live-migration-permit-auto-converge: true
      config-flags: default_ephemeral_format=ext4
      resume-guests-state-on-host-boot: false
      action-managed-upgrade: true
      ceph-osd-replication-count: 1
      libvirt-image-backend: rbd
      cpu-mode: host-passthrough
      enable-resize: true
      flat-interface: ens3
    annotations:
      gui-x: '250'
      gui-y: '250'
    bindings:
      ? ''
      : internal
    num_units: 2
    to:
      - '1'
      - '2'
  nova-cloud-controller:
    series: bionic
    charm: 'cs:nova-cloud-controller-328'
    options:
      openstack-origin: 'cloud:bionic-stein'
      action-managed-upgrade: true
      console-access-protocol: novnc
      network-manager: Neutron
      worker-multiplier: 0.25
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '0'
      gui-y: '500'
    num_units: 1
    to:
      - lxd:0
  ceph-mon:
    charm: 'cs:ceph-mon-38'
    series: bionic
    options:
      source: 'cloud:bionic-stein'
      expected-osd-count: 3
      monitor-count: 3
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '750'
      gui-y: '500'
    num_units: 3
    to:
      - 'lxd:0'
      - 'lxd:1'
      - 'lxd:2'
  ceph-radosgw:
    series: bionic
    charm: 'cs:ceph-radosgw-270'
    options:
      source: 'cloud:bionic-stein'
      ceph-osd-replication-count: 1
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '1000'
      gui-y: '250'
    num_units: 1
    to:
      - 'lxd:0'
  cinder:
    charm: 'cs:cinder-284'
    series: bionic
    options:
      openstack-origin: 'cloud:bionic-stein'
      worker-multiplier: 0.25
      block-device: None
      glance-api-version: 2
      action-managed-upgrade: true
      ceph-osd-replication-count: 1
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '750'
      gui-y: '0'
    num_units: 1
    to:
      - 'lxd:0'
  cinder-ceph:
    charm: 'cs:cinder-ceph-242'
    options:
      ceph-osd-replication-count: 1
    annotations:
      gui-x: '750'
      gui-y: '250'
    num_units: 0
  glance:
    series: bionic
    charm: 'cs:glance-279'
    options:
      openstack-origin: 'cloud:bionic-stein'
      action-managed-upgrade: true
      ceph-osd-replication-count: 1
      worker-multiplier: 0.25
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '250'
      gui-y: '0'
    num_units: 1
    to:
      - 'lxd:0'
  keystone:
    charm: 'cs:keystone-299'
    series: bionic
    options:
      openstack-origin: 'cloud:bionic-stein'
      admin-password: admin
      worker-multiplier: 0.25
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '500'
      gui-y: '0'
    num_units: 1
    to:
      - 'lxd:0'
  mysql:
    charm: 'cs:percona-cluster-276'
    series: bionic
    options:
      sst-password: admin
      root-password: admin
      innodb-buffer-pool-size: 256M
      max-connections: 2000
      performance-schema: true
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '0'
      gui-y: '250'
    num_units: 1
    to:
      - 'lxd:0'
  neutron-api:
    charm: 'cs:neutron-api-273'
    series: bionic
    options:
      openstack-origin: 'cloud:bionic-stein'
      worker-multiplier: 0.25
      neutron-security-groups: true
      action-managed-upgrade: true
      dns-domain: mini-stack.maas.
      enable-ml2-dns: true
      enable-vlan-trunking: true
      global-physnet-mtu: 1500
      flat-network-providers: physnet1
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '500'
      gui-y: '500'
    num_units: 1
    to:
      - 'lxd:0'
  neutron-openvswitch:
    charm: 'cs:neutron-openvswitch-259'
    num_units: 0
    options:
      firewall-driver: openvswitch
      verbose: true
      debug: true
    annotations:
      gui-x: '250'
      gui-y: '500'
    bindings:
      ? ''
      : internal
  ntp:
    charm: 'cs:ntp-32'
    options:
      pools: >-
        0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org 2.ubuntu.pool.ntp.org
        3.ubuntu.pool.ntp.org ntp.ubuntu.com
    annotations:
      gui-x: '1000'
      gui-y: '0'
    num_units: 0
  openstack-dashboard:
    series: bionic
    charm: 'cs:openstack-dashboard-280'
    options:
      openstack-origin: 'cloud:bionic-stein'
      action-managed-upgrade: true
      allow-password-autocompletion: true
      password-retrieve: true
      default-create-volume: true
      default-domain: admin_domain
      webroot: '/'
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '500'
      gui-y: '-250'
    num_units: 1
    to:
      - 'lxd:0'
  rabbitmq-server:
    series: bionic
    charm: 'cs:rabbitmq-server-89'
    options:
      ceph-osd-replication-count: 1
      management_plugin: true
    bindings:
      ? ''
      : internal
    annotations:
      gui-x: '500'
      gui-y: '250'
    num_units: 1
    to:
      - 'lxd:0'
relations:
- - nova-compute:amqp
  - rabbitmq-server:amqp
- - neutron-gateway:amqp
  - rabbitmq-server:amqp
- - keystone:shared-db
  - mysql:shared-db
- - nova-cloud-controller:identity-service
  - keystone:identity-service
- - glance:identity-service
  - keystone:identity-service
- - neutron-api:identity-service
  - keystone:identity-service
- - neutron-openvswitch:neutron-plugin-api
  - neutron-api:neutron-plugin-api
- - neutron-api:shared-db
  - mysql:shared-db
- - neutron-api:amqp
  - rabbitmq-server:amqp
- - neutron-gateway:neutron-plugin-api
  - neutron-api:neutron-plugin-api
- - glance:shared-db
  - mysql:shared-db
- - glance:amqp
  - rabbitmq-server:amqp
- - nova-cloud-controller:image-service
  - glance:image-service
- - nova-compute:image-service
  - glance:image-service
- - nova-cloud-controller:cloud-compute
  - nova-compute:cloud-compute
- - nova-cloud-controller:amqp
  - rabbitmq-server:amqp
- - nova-cloud-controller:quantum-network-service
  - neutron-gateway:quantum-network-service
- - nova-compute:neutron-plugin
  - neutron-openvswitch:neutron-plugin
- - neutron-openvswitch:amqp
  - rabbitmq-server:amqp
- - openstack-dashboard:identity-service
  - keystone:identity-service
- - openstack-dashboard:shared-db
  - mysql:shared-db
- - nova-cloud-controller:shared-db
  - mysql:shared-db
- - nova-cloud-controller:neutron-api
  - neutron-api:neutron-api
- - cinder:image-service
  - glance:image-service
- - cinder:amqp
  - rabbitmq-server:amqp
- - cinder:identity-service
  - keystone:identity-service
- - cinder:cinder-volume-service
  - nova-cloud-controller:cinder-volume-service
- - cinder-ceph:storage-backend
  - cinder:storage-backend
- - ceph-mon:client
  - nova-compute:ceph
- - nova-compute:ceph-access
  - cinder-ceph:ceph-access
- - cinder:shared-db
  - mysql:shared-db
- - ceph-mon:client
  - cinder-ceph:ceph
- - ceph-mon:client
  - glance:ceph
- - ceph-osd:mon
  - ceph-mon:osd
- - ntp:juju-info
  - nova-compute:juju-info
- - ntp:juju-info
  - neutron-gateway:juju-info
- - ceph-radosgw:mon
  - ceph-mon:radosgw
- - ceph-radosgw:identity-service
  - keystone:identity-service
EOFEOF
}

write_yaml
