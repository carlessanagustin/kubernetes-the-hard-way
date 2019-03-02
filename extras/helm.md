# Install Helm

```shell
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.7.0-linux-amd64.tar.gz
tar zxvf helm-v2.7.0-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule \
    --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init
kubectl -n kube-system patch deployment tiller-deploy \
    -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
source <(helm completion bash)
```
