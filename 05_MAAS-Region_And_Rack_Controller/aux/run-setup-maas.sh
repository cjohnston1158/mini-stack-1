#!/bin/bash
##################################################################################
# Stage maas network config routine
stage_setup () {
echo ">  Staging Configuration Script ..."
cat <<EOF >/tmp/run-maas-setup
#!/bin/bash 
##################################################################################
upstream_DNS="8.8.8.8"
echo ">  Running maas network configuration ..."  
##################################################################################
# MAAS Login Admin
run_maas_login () {

  login-maas-cli
  login_CODE="\$?"
  [[ \${login_CODE} == "0" ]] || echo "Login Failed"
  [[ \${login_CODE} == "0" ]] || exit 1

}

##################################################################################
# Find Rack ID
find_maas_rack_id () {

  primary_RACK=\$(maas admin rack-controllers read \
                                | jq ".[] | {system_id:.system_id}" \
                                | awk -F'[",]' '/system_id/{print \$4}' \
              )

}

##################################################################################
# Run MaaS Network Config
run_maas_setup () {

  # MAAS Controller Config
  maas admin maas set-config name=maas_name value=maasctl
  maas admin maas set-config name=upstream_dns value=\${upstream_DNS}
  maas admin maas set-config name=enable_third_party_drivers value=true
  maas admin maas set-config name=disk_erase_with_secure_erase value=false

  # Set Kernel Parameter
  maas admin maas set-config name=kernel_opts \
    value='debug console=ttyS0,38400n8 console=tty0 intel_iommu=on iommu=pt kvm_intel.nested=1 net.ifnames=0 biosdevname=0 pci=noaer'

  # Create Spaces
  maas admin spaces create name=internal
  maas admin spaces create name=external

  # Configure 'Internal' Network
  maas admin fabric update 0 name=internal
  maas admin subnet update 1 name=untagged-internal \
    gateway_ip="${ministack_SUBNET}.1" dns_servers="${ministack_SUBNET}.10"
  maas admin ipranges create type=dynamic \
    start_ip=${ministack_SUBNET}.100 end_ip=${ministack_SUBNET}.240
  maas admin vlan update internal 0 name=internal space=internal
  maas admin vlan update internal untagged dhcp_on=True primary_rack=\${primary_RACK}

}

##################################################################################
service_reload () {

  systemctl restart maas-regiond
  sleep 5
  systemctl restart maas-rackd

}

##################################################################################
run () {

  run_maas_login
  find_maas_rack_id
  run_maas_setup
  service_reload 
  echo "Finished run-maas-setup at \$(date)"

}

run
EOF
chmod +x /tmp/run-maas-setup
}

##################################################################################
run () {
  
  # Load Profile
  source /etc/ccio/mini-stack/profile

  # Stage Config
  stage_setup

  # Load Config
  lxc file push /tmp/run-maas-setup maasctl/bin/run-maas-setup

  # Run Config
  lxc exec maasctl run-maas-setup

}

run
