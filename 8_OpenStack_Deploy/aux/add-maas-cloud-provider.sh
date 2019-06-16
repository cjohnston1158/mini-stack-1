#!/bin/bash -x
##########################################################################################
# Stage juju cloud config(s)
stage_config () {

# Write maas cloud yaml
cat <<EOF > /tmp/maasctl-cloud.yaml
clouds:
  maasctl:
    type: maas
    auth-types: [oauth1]
    endpoint: http://${ministack_SUBNET}.10:5240/MAAS
EOF

# Write maas cloud credentials yaml
cat <<EOF > /tmp/maasctl-credentials.yaml
credentials:
  maasctl:
    admin:
      auth-type: oauth1
      maas-oauth: ${MAASCTL_API_KEY}
EOF

# Set Permissions Open
chmod 777 -R /tmp/maasctl*.yaml
}

##########################################################################################
# Stage Enroll Script
stage_enroll () {
cat <<EOF >/tmp/juju-enroll-maas-provider.sh
#!/bin/bash
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
# Run
run () {
  add_clouds
  show_clouds
}

run
EOF
chmod 777 /tmp/juju-enroll-maas-provider.sh
}

##########################################################################################
load_config () {
  lxc file push /tmp/juju-enroll-maas-provider.sh cloudctl/tmp/
  lxc file push /tmp/maasctl-cloud.yaml cloudctl/tmp/
  lxc file push /tmp/maasctl-credentials.yaml cloudctl/tmp/
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
  load_profile
  stage_config
  stage_enroll
  load_config
}

run
