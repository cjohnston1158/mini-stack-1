
```
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
systemctl set-default multi-user.target && systemctl default 
cp -f /etc/skel/.bashrc ~/.bashrc
mkdir /etc/default/grub.d
wget -P /etc/default/grub.d/ https://raw.githubusercontent.com/KathrynMorgan/mini-stack/master/0_Host_System_Prep/aux/libvirt-grub.cfg
update-grub
reboot
```
