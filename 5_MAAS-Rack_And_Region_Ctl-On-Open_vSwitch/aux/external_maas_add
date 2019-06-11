#!/bin/bash -x
#################################################################################
source /etc/ccio/mini-stack/profile

#################################################################################
add_iface () {
echo ">  Attaching 'external' network on interface 'eth1'..."
lxc network attach external maasctl eth1 eth1
lxc exec maasctl -- /bin/bash -c 'netplan apply --debug'
}

stage_config () {
echo ">  Staging Configuration Script ..."
cat <<EOF >/tmp/run_maas_setup
#!/bin/bash 

echo ">  Running maas network configuration ..."  
set -x

run_maas_login () {
login-maas-cli
[[ $? == "0" ]] || echo "Login Failed"
[[ $? == "0" ]] || exit 1
}

find_maas_rack_id () {
primary_RACK=\$(maas admin rack-controllers read \
                                | jq ".[] | {system_id:.system_id}" \
                                | awk -F'[",]' '/system_id/{print \$4}' \
              )
}

run_maas_setup () {

maas admin fabric update 1 name=external
maas admin spaces create name=external
maas admin subnet update 1 name=untagged-external
maas admin vlan update external 0 name=external space=external

}

run_maas_login
find_maas_rack_id
run_maas_setup

echo "Finished run_maas_setup at \$(date)"

EOF

chmod +x /tmp/run_maas_setup
}

load_config () {
echo ">  Loading maas configuration script"
lxc file push /tmp/run_maas_setup maasctl/bin/run_maas_setup
}

restart_maasctl () {
echo '>  Restarting MaasCTL'
lxc stop maasctl
sleep 1
ovs-clear
lxc start maasctl
sleep 1
lxc list
}

exec_config () {
echo ">  Configuring 'external' network bridge..."
lxc exec maasctl run_maas_setup
lxc exec maasctl run_maas_setup
}

run () {
add_iface
stage_config
load_config
restart_maasctl
exec_config
}

run

