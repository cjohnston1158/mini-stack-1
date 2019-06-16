#!/bin/bash -x
#################################################################################
# Stage maas network config routine
stage_setup () {
echo ">  Staging Configuration Script ..."
cat <<EOF >/tmp/run-maas-setup
#!/bin/bash 
##################################################################################
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
# Run MAAS Network Config
run_maas_setup () {

  # Configue 'External' Network
  maas admin spaces create name=external
  maas admin fabric update 1 name=external
  maas admin subnet update 1 name=external
  maas admin vlan update external 0 name=external space=external

}

##################################################################################
# Reload Region & Rack Services
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
  echo "Finished run-maas-setup at \$(date)"

}

run
EOF

chmod +x /tmp/run-maas-setup
}

##################################################################################
add_iface () {

  echo ">  Attaching 'external' network on interface 'eth1'..."

  lxc network attach external maasctl eth1 eth1
  lxc exec maasctl -- /bin/bash -c 'netplan apply --debug'

}

##################################################################################
run () {

  # Load Profile
  source /etc/ccio/mini-stack/profile

  # Attach 'External' Iface 'eth1'
  add_iface

  # Stage Config
  stage_setup

  # Load Config
  echo ">  Loading maas configuration script"
  lxc file push /tmp/run-maas-setup maasctl/bin/run-maas-setup

  # Run Config
  echo ">  Configuring 'external' network bridge..."
  lxc exec maasctl -- run-maas-setup

}

run
