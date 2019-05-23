#!/usr/bin/env bash
# Openstack User RC File
#################################################################################
# User Credentials
export OS_PASSWORD="admin"
export OS_USERNAME="admin"
export OS_PROJECT_NAME="admin"
export OS_REGION_NAME="RegionOne"
export OS_USER_DOMAIN_NAME="admin_domain"

#################################################################################
# Cloud API Access
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_URL=http://10.10.0.247:5000/v3
export OS_PROJECT_ID=8bce2c5645534896af2ad6ea9b0ec578
export OS_PROJECT_DOMAIN_ID="8d5e2889070f4dabaf2f841e63f32809"

#################################################################################
# Safety Check
unset OS_TENANT_ID
unset OS_TENANT_NAME
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
