#!/bin/bash

apt update
apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# add dependencies
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu    $(lsb_release -cs)    stable"

# install docker
apt update
apt install -y 'docker-ce=18.06.1~ce~3-0~ubuntu'
apt install docker-ce-cli containerd.io -y
systemctl start docker
systemctl enable docker

# install kubernetes
apt install -y kubelet kubeadm kubectl kubernetes-cni
systemctl start kubelet
systemctl enable kubelet

# initialize cluster
kubeadm init --token ${KUBEADM_TOKEN} --pod-network-cidr=10.244.0.0/16

# install pod network plugin
mkdir -p /etc/cni/net.d 
cat > /etc/cni/net.d/10-flannel.conflist <<EOF 
{ "name": "cbr0", "plugins": [ { "type": "flannel", "delegate": { "hairpinMode": true, "isDefaultGateway": true } }, { "type": "portmap", "capabilities": { "portMappings": true } } ] }
EOF
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# kubectl apply -f http://docs.projectcalico.org/v2.3/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown -R root:root /root/.kube

sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
sleep 300
# configure kubectl for user ubuntu 
mkdir -p /home/ubuntu/.kube
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
echo "completed" > /tmp/kube
