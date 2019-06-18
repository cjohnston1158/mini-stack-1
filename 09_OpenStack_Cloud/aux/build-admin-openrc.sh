#!/usr/bin/env bash
export OS_AUTH_URL=http://$(juju status keystone | grep "keystone/0" | awk '{print $5}'):5000/v3
export OS_PROJECT_ID=dbaef650e0dd4f608485e43c993cea0d
export OS_PROJECT_NAME="admin"
export OS_USER_DOMAIN_NAME="admin_domain"
export OS_PROJECT_DOMAIN_ID="be75d6b084414c7eae4b2e1e125a3138"
unset OS_TENANT_ID
unset OS_TENANT_NAME
export OS_USERNAME="admin"
export OS_PASSWORD="$(juju run --unit keystone/0 leader-get admin_passwd)"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
