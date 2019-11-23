#!/bin/bash

#install basic environment for kubernetess master
sudo apt-get update
sudo apt-get install -y openssh-server
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo docker --version
sudo apt-get install -y curl
sudo su -c 'curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add' root
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get install -y kubeadm
sudo swapoff -a

#initilize kubernetes 



sudo kubeadm init --token ja8t1s.vtth26cqwd21mz9k   --pod-network-cidr=40.160.0.0/16 --ignore-preflight-errors=NumCPU  

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#install flannel networks
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#install kubernetes dashborad

kubectl get pods --all-namespaces
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl get pods --all-namespaces

# create a service account
kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
#start kubernetes proxy
kubectl proxy --address='0.0.0.0' --accept-hosts='^*$'  &
curl http://localhost:8001

#get a dash board token 
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode



