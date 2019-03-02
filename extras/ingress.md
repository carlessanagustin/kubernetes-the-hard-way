# NGINX Ingress Controllers for Kubernetes

## Setup ingress controller as daemonset

```shell
git clone https://github.com/nginxinc/kubernetes-ingress.git
cd kubernetes-ingress
# instructions: https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/installation.md
kubectl create -f common/ns-and-sa.yaml
kubectl create -f common/default-server-secret.yaml
kubectl create -f common/nginx-config.yaml
kubectl create -f rbac/rbac.yaml
kubectl create -f daemon-set/nginx-ingress.yaml
kubectl create -f service/nodeport.yaml
watch kubectl get pods,svc --namespace=nginx-ingress
```


## Test with pod

```shell
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment web --type=ClusterIP --port=8080
cat << EOF > example-ingress.yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
 rules:
 - host: hello-world.info
   http:
     paths:
     - path: /
       backend:
         serviceName: web
         servicePort: 8080
EOF
kubectl create -f example-ingress.yaml
curl -H 'Host: hello-world.info' 'http://127.0.0.1'
```

# Clean up

```shell
kubectl delete namespace nginx-ingress
kubectl delete ingresses.extensions example-ingress
kubectl delete svc web
kubectl delete deployments web
```
