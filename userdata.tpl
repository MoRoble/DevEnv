#!/bin/bash

#install terraform
sudo apt-get update -y
sudo apt-get install wget
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install terraform -y

#install aws-cli
sudo apt-get install awscli -y
aws configure
test
test
test



#clone DevEng git repo
sudo apt-get update -y
git clone https://github.com/MoRoble/DevEnv.git
cd DevEnv
# git remote set-url origin https://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@github.com/MoRoble/DevEnv.git
# git checkout ec2-only

#install docker
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker ubuntu


#cd ~/.ssh && cp authorized_keys devenv