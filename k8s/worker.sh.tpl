#!/bin/bash

apt update
apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# add repositories
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu    $(lsb_release -cs)    stable"

# install docker
apt update
apt install 'docker-ce=18.06.1~ce~3-0~ubuntu' -y
apt install docker-ce-cli containerd.io -y
systemctl start docker
systemctl enable docker

# install kubernetes
apt install -y kubelet kubeadm kubectl kubernetes-cni
mkdir -p /etc/cni/net.d 
cat > /etc/cni/net.d/10-flannel.conflist <<EOF 
{ "name": "cbr0", "plugins": [ { "type": "flannel", "delegate": { "hairpinMode": true, "isDefaultGateway": true } }, { "type": "portmap", "capabilities": { "portMappings": true } } ] }
EOF
systemctl start kubelet
systemctl enable kubelet

#sleep 300

# join nodes to cluster
kubeadm join --token ${KUBEADM_TOKEN} ${MASTER_IP}:6443 --discovery-token-unsafe-skip-ca-verification

#systemctl restart kubelet
