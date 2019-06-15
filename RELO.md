
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
#### 00. ALIAS
````sh
echo "  ${ccio_SSH_UNAME}: exec @ARGS@ -- sudo --login --user ${ccio_SSH_UNAME}" >> ~/.config/lxc/config.yml
````
