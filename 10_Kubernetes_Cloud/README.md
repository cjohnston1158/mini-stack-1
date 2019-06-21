# Part 9 -- Kubernetes Deploy
###### Prepare and Deploy Kubernetes with Juju

-------
Prerequisites:
- [Part 0 Host System Prep]
- [Part 1 Single Port Host OVS Network]
- [Part 2 LXD On Open vSwitch Network]
- [Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]
- [Part 4 KVM On Open vSwitch]
- [Part 5 MAAS Region And Rack Server on OVS Sandbox]
- [Part 6 MAAS Connect POD on KVM Provider]
- [Part 7 Juju MAAS Cloud]
- [Part 8 OpenStack Deploy]


![CCIO Hypervisor - OpenStack Prep](web/drawio/OpenStack-Prep.svg)

-------
#### 01.
```
wget -qO- http://${ministack_SUBNET}.3/mini-stack/10_Kubernetes_Cloud/aux/virt-inst-k8s-nodes.sh | bash
```
```
lxc exec maasctl -- maas-nodes-discover
```
```
lxc exec maasctl -- /bin/bash -c "wget -qO- http://${ministack_SUBNET}.3/mini-stack/10_Kubernetes_Cloud/aux/maas-tag-nodes | bash"
```
```
wget -qO /tmp/kubernetes.yaml http://${ministack_SUBNET}.3/mini-stack/10_Kubernetes_Cloud/aux/mini-k8s-juju-bundle_v01.yaml
```
```
juju deploy /tmp/kubernetes.yaml --verbose --debug
```
```
mkdir -p ~/.kube
juju scp kubernetes-master/0:config ~/.kube/config
snap install kubectl --classic
kubectl cluster-info
juju expose kubernetes-worker
```
https://10.10.0.46/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/cluster?namespace=default
###### Credentials: [admin:admin]

###### How To Ingress
https://github.com/kubernetes-retired/contrib/tree/master/ingress/controllers/nginx/examples

###### Kubernetes Storage
https://ubuntu.com/kubernetes/docs/storage

###### MetalLB
https://metallb.universe.tf/tutorial/layer2/

-------
<!-- Markdown link & img dfn's -->
[Part 0 Host System Prep]: ../0_Host_System_Prep
[Part 1 Single Port Host OVS Network]: ../1_Single_Port_Host-Open_vSwitch_Network_Configuration
[Part 2 LXD On Open vSwitch Network]: ../2_LXD-On-OVS
[Part 3 LXD Gateway & Firwall for Open vSwitch Network Isolation]: ../3_LXD_Network_Gateway
[Part 4 KVM On Open vSwitch]: ../4_KVM_On_Open_vSwitch
[Part 5 MAAS Region And Rack Server on OVS Sandbox]: ../5_MAAS-Rack_And_Region_Ctl-On-Open_vSwitch
[Part 6 MAAS Connect POD on KVM Provider]: ../6_MAAS-Connect_POD_KVM-Provider
[Part 7 Juju MAAS Cloud]: ../7_Juju_MAAS_Cloud
[Part 8 OpenStack Prep]: ../8_OpenStack_Deploy
