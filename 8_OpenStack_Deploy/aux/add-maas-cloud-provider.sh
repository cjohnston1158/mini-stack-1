#!/bin/bash
##########################################################################################
# Stage juju cloud config(s)
stage_config () {

# Write maas cloud yaml
cat <<EOF > /tmp/juju/maasctl.yaml
clouds:
  maasctl:
    type: maas
    auth-types: [oauth1]
    endpoint: http://${ministack_SUBNET}.10:5240/MAAS
EOF

# Write maas cloud credentials yaml
cat <<EOF > /tmp/juju/credentials-maasctl.yaml
credentials:
  maasctl:
    admin:
      auth-type: oauth1
      maas-oauth: ${MAASCTL_API_KEY}
EOF

chmod 777 -R /tmp/juju
}

##########################################################################################
# Add cloud from config
add_clouds () {
  juju add-cloud maasctl /tmp/maasctl-cloud.yaml
  juju add-credential maasctl -f /tmp/maasctl-credentials.yaml
}

##########################################################################################
# Add cloud from config
show_clouds () {
  juju clouds
  juju credentials
}

##########################################################################################
load_config () {
  lxc file push /tmp/maasctl-cloud.yaml
  lxc file push /tmp/maasctl-credentials.yaml
}

##########################################################################################
# Load Profile
load_profile () {
  source /etc/ccio/mini-stack/profile
  MAASCTL_API_KEY=$(lxc exec maasctl -- maas-region apikey --username=admin)
}

##########################################################################################
# Run
run () {
  stage_config
  load_config
  add_clouds
  show_clouds
}

run
