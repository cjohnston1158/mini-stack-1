#!/bin/bash

# Launch Instance
openstack server create \
	--flavor m2.2small \
	--image generic-bionic \
	--key-name cloudctl \
	--security-group 5ece6869-5d5b-45d6-86b6-d9716018b02f \
	--nic net-id=85a452ac-df6d-46f4-9f81-d221d3abb3f9 \
	t01

# Associate Floating IP
openstack server add floating ip t01 ${ministack_SUBNET}.66
