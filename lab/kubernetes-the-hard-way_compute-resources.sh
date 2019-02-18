#!/usr/bin/env bash

# Provisioning Compute Resources
region_zone(){
	gcloud config set project csanagustin-lfs258
	gcloud config set compute/region us-west1
	gcloud config set compute/zone us-west1-c
}

config(){
	gcloud config list
}

create_network(){
	gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom
}

create_subnet(){
	gcloud compute networks subnets create kubernetes --network kubernetes-the-hard-way --range 10.240.0.0/24
}

create_firewall_rules(){
	gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal --allow tcp,udp,icmp --network kubernetes-the-hard-way --source-ranges 10.240.0.0/24,10.200.0.0/16
	gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external --allow tcp:22,tcp:6443,icmp --network kubernetes-the-hard-way --source-ranges 0.0.0.0/0
	gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"
}

create_public_ip(){
	gcloud compute addresses create kubernetes-the-hard-way --region $(gcloud config get-value compute/region)
	gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"
}

# 3x controllers = HA master
create_controllers(){
	for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,controller
  done
}

# 3x workers
create_workers(){
	for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
  done
}

list_instances(){
	gcloud compute instances list
}
