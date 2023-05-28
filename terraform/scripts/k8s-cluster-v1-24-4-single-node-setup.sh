#!/bin/bash

apt-get update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y      
apt-get update
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
 echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y containerd.io docker-ce-cli


#Configure iptables

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

#Add the Kubernetes apt repository and public signing key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo 'deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubelet kubectl and kubeadm


apt-get update
apt-get install -y kubelet=1.24.4-00 kubeadm=1.24.4-00 kubectl=1.24.4-00
apt-mark hold kubelet kubeadm kubectl

# Disable swap memory

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#Enable and restart the services containerd and kubelet

systemctl enable kubelet
systemctl restart kubelet
#rm /etc/containerd/config.toml
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
systemctl daemon-reload

# Set hostname as private ipv4 dnsname from the instance metadata

hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)

cluster_name = $1
imdstoken=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 300" "http://169.254.169.254/latest/api/token")

# Create a kubeadm configuration file which will be used during init
cat <<EOF> /tmp/kubeconfigold.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  extraArgs:
    cloud-provider: aws
clusterName: k8s
controlPlaneEndpoint: $(curl -H "X-aws-ec2-metadata-token: $imdstoken" http://169.254.169.254/latest/meta-data/local-ipv4):6443
controllerManager:
  extraArgs:
    cloud-provider: aws
    configure-cloud-routes: 'false'
kubernetesVersion: v1.24.4
networking:
  dnsDomain: cluster.local
  podSubnet: 192.168.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler:
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  name: '$(curl -H "X-aws-ec2-metadata-token: $imdstoken" http://169.254.169.254/latest/meta-data/hostname)'
  kubeletExtraArgs:
    cloud-provider: aws
EOF

# controlplane endpoint and node registration name will come from the instance metadata. 


# Migrate kubeconfig to a version compatible with the current kubeadm version
 kubeadm config migrate --old-config /tmp/kubeconfigold.yaml --new-config /tmp/kubeconfig.yaml
export HOME=/root
# Creates the kubernetes cluster using the config file
kubeadm init --config /tmp/kubeconfig.yaml

# Copy config file to .kube directory under the user's home directory 
mkdir -p ~/.kube
mkdir -p /home/ubuntu/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube
#Make master node schedulable
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
#Install calico CNI
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml

#EBS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.11"

# Create a storageclass resource definition file
cat <<EOF> /tmp/sc-ebs-csi.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-csi
provisioner: ebs.csi.aws.com
volumeBindingMode: Immediate
parameters:
  csi.storage.k8s.io/fstype: ext4
  type: gp3
  encrypted: "true"
EOF
#Apply the above file and create storage class. Make it default
kubectl apply -f /tmp/sc-ebs-csi.yaml
kubectl patch storageclass ebs-csi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


echo "######### Kubernetes Cluster Creation is Complete   #########"

echo "####### Verify using kubectl commands #########"