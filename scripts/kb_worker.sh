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
#add nodes to kubernetes cluster

sudo kubeadm join  $1:6443 --token ja8t1s.vtth26cqwd21mz9k   --discovery-token-unsafe-skip-ca-verification
