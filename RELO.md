
#### 02. Create host CCIO Profile Configuration && add to bashrc
```sh
wget -O /tmp/build-mini-stack-profile.sh https://git.io/fjgep
source /tmp/build-mini-stack-profile.sh
```
#### 03. Import your ssh pub key
```sh
ssh-import-id ${ccio_SSH_SERVICE}:${ccio_SSH_UNAME}
```
#### 04. Enable root user ssh login
```sh
sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
systemctl restart sshd
```
#### 00. Acquire MaasCTL MAAS API Key
````sh
export MAASCTL_API_KEY=$(lxc exec maasctl -- maas-region apikey --username=admin)
````

### BOOTSTRAP JUJUCTL
#### 04. Virsh Build MAAS Cloud JujuCtl Node
````sh
wget -O- https://git.io/fj87R | bash

#### 05. Import JujuCtl Virsh Node
````sh
lxc exec maasctl -- /bin/bash -c 'login-maas-cli'
lxc exec maasctl -- /bin/bash -c 'wget -O- https://git.io/fj87E | bash'
````
#### 06. Tag JujuCtl Virsh Node
````sh
lxc exec maasctl -- /bin/bash -c 'wget -O- https://git.io/fj87u | bash'
````
  - NOTE: wait for jujuctl.maas node to show as 'ready' in maasctl webui indicating 'comissioning' is complete
#### 07. Check CloudCtl MaasCtl Cloud && Bootstrap JujuCtl Controller Node
````sh
lxc exec cloudctl -- /bin/bash -c "passwd ${ccio_SSH_UNAME}"
lxc exec cloudctl -- login ${ccio_SSH_UNAME}
juju clouds
juju credentials
juju bootstrap --bootstrap-series=bionic --config bootstrap-timeout=1800 --constraints "tags=jujuctl" maasctl jujuctl
exit
````
  - NOTE: JujuCtl Comissioning may take some time, wait till complete to continue
#### 08. Set Juju WebUI Password
````sh
lxc exec cloudctl -- su -l ${ccio_SSH_UNAME} -c 'yes admin | juju change-user-password admin'
````
#### 09. Find juju WebUI
````sh
lxc exec cloudctl -- su -l ${ccio_SSH_UNAME} -c 'juju gui'
````
