#!/usr/bin/env bash

source ./kubernetes-the-hard-way_compute-resources.sh
source ./kubernetes-the-hard-way_tls-certificates.sh
source ./kubernetes-the-hard-way_configfiles-auth.sh

# Generating the Data Encryption Config and Key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done

## The commands in this lab must be run on each controller instance: controller-0, controller-1, and controller-2.
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp kubernetes-the-hard-way_etcd.sh ${instance}:~/
	gcloud compute ssh ${instance} --command "bash ~/kubernetes-the-hard-way_etcd.sh"
done

## The commands in this lab must be run on each controller instance: controller-0, controller-1, and controller-2.
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp kubernetes-the-hard-way_k8s-control-plane.sh ${instance}:~/
	gcloud compute ssh ${instance} --command "bash ~/kubernetes-the-hard-way_k8s-control-plane.sh"
done

gcloud compute scp kubernetes-the-hard-way_rbac-for-kubelet.sh controller-0:~/
gcloud compute ssh controller-0 --command "bash ~/kubernetes-the-hard-way_rbac-for-kubelet.sh"

# Provision a Network Load Balancer (GCP)
Provision_GCP_Load_Balancer(){
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  gcloud compute http-health-checks create kubernetes \
    --description "Kubernetes Health Check" \
    --host "kubernetes.default.svc.cluster.local" \
    --request-path "/healthz"

  gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
    --network kubernetes-the-hard-way \
    --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
    --allow tcp

  gcloud compute target-pools create kubernetes-target-pool \
    --http-health-check kubernetes

  gcloud compute target-pools add-instances kubernetes-target-pool \
   --instances controller-0,controller-1,controller-2

  gcloud compute forwarding-rules create kubernetes-forwarding-rule \
    --address $KUBERNETES_PUBLIC_ADDRESS \
    --ports 6443 \
    --region $(gcloud config get-value compute/region) \
    --target-pool kubernetes-target-pool
}

Verify_Provision_GCP_Load_Balancer(){
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')
  curl --cacert ca.pem https://$KUBERNETES_PUBLIC_ADDRESS:6443/version
}

## The commands in this lab must be run on each worker instance: worker-0, worker-1, and worker-2.
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp kubernetes-the-hard-way_k8s-worker-nodes.sh ${instance}:~/
	gcloud compute ssh ${instance} --command "bash ~/kubernetes-the-hard-way_k8s-worker-nodes.sh"
done

# Verification
gcloud compute ssh controller-0 \
  --command "kubectl get nodes --kubeconfig admin.kubeconfig"

# Configuring kubectl for Remote Access
kubectl_remote(){
  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://$KUBERNETES_PUBLIC_ADDRESS:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
}
# Verification
kubectl get componentstatuses

# Provisioning Pod Network Routes
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done

for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done

gcloud compute routes list --filter "network: kubernetes-the-hard-way"

# Deploying the DNS Cluster Add-on
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
kubectl get pods -l k8s-app=kube-dns -n kube-system

# Verification
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
sleep 10
kubectl exec -ti $(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}") -- nslookup kubernetes
kubectl delete deployment busybox

# Smoke Test
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"

# Data Encryption
gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

# Deployments
kubectl run nginx --image=nginx
kubectl get pods -l run=nginx

POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
# Port Forwarding
kubectl port-forward $POD_NAME 8080:80 &
curl --head http://127.0.0.1:8080

# Logs
kubectl logs $POD_NAME

# Exec
kubectl exec -ti $POD_NAME -- nginx -v

# Services
kubectl expose deployment nginx --port 80 --type NodePort
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:$NODE_PORT \
  --network kubernetes-the-hard-way
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
curl -I http://$EXTERNAL_IP:$NODE_PORT

# TODO: Untrusted Workloads

# Cleaning Up
# source ./kubernetes-the-hard-way_clean-up.sh
