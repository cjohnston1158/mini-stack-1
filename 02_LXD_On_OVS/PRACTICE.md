## PRACTICE
##### (A) Launch && Acquire Shell / Exit Shell && Delete Containers
````sh
lxc launch ubuntu:bionic c01
lxc launch images:centos/7 test-centos

lxc list

lxc ubuntu c01
exit

lxc ${ministack_UNAME} c01
exit

lxc exec c01 bash
exit

lxc delete c01 --force
lxc delete test-centos --force
````
##### (B) Check LXD Configurations
````sh
lxc network list
lxc network show external

lxc profile list
lxc profile show default

lxc config show c01
````
