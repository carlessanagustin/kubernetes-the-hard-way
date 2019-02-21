#!/usr/bin/env bash

controller_worker_instances(){
  gcloud -q compute instances delete \
    controller-0 controller-1 controller-2 \
    worker-0 worker-1 worker-2
}

delete_external_load_balancer(){
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
    --region $(gcloud config get-value compute/region)
  gcloud -q compute target-pools delete kubernetes-target-pool
  gcloud -q compute http-health-checks delete kubernetes
  gcloud -q compute addresses delete kubernetes-the-hard-way
}

delete_firewall_rules(){
  gcloud -q compute firewall-rules delete \
    kubernetes-the-hard-way-allow-nginx-service \
    kubernetes-the-hard-way-allow-internal \
    kubernetes-the-hard-way-allow-external \
    kubernetes-the-hard-way-allow-health-check
}

delete_network_VPC(){
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24 \
    kubernetes-route-10-200-2-0-24
  gcloud -q compute networks subnets delete kubernetes
  gcloud -q compute networks delete kubernetes-the-hard-way
}

controller_worker_instances
delete_external_load_balancer
delete_firewall_rules
delete_network_VPC
