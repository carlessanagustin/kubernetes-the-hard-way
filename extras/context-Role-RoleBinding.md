# Authentication and Authorization

* User setup

```shell
USER_NAME=DevDan

kubectl create ns development
kubectl create ns production

sudo useradd -m -d /home/$USER_NAME -s /bin/bash $USER_NAME
sudo passwd $USER_NAME
```

* certificates

```shell
openssl genrsa -out $USER_NAME.key 2048
openssl req -new -key $USER_NAME.key -out $USER_NAME.csr -subj "/CN=$USER_NAME/O=development"
sudo openssl x509 -req -in $USER_NAME.csr \
  -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out $USER_NAME.crt -days 365
```

* kubeconfig

```shell
# kubectl config set-cluster <cluster_name> --kubeconfig=config-demo  --server=https://<new_cluster_ip> --certificate-authority=<ca_file>
kubectl config set-credentials $USER_NAME \
    --client-certificate=$USER_NAME.crt \
    --client-key=$USER_NAME.key

kubectl config set-context $USER_NAME-context \
    --cluster=kubernetes \
    --namespace=development \
    --user=$USER_NAME
```

* test: `kubectl --context=DevDan-context get pods`
* error right? continue...

```shell
cat << EOF | kubectl create -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer
  namespace: development
rules:
- apiGroups: [ "", "extensions", "apps" ]
  resources: [ "deployments", "replicasets", "pods"]
  verbs: [ "list", "get", "watch", "create", "update", "patch", "delete" ]
EOF

cat << EOF | kubectl create -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: developer-role-binding
  namespace: development
subjects:
- kind: User
  name: DevDan
  apiGroup: ""
roleRef:
  kind: Role
  name: developer
  apiGroup: ""
EOF
kubectl --context=DevDan-context get pods
```

## Documentation

* https://kubernetes.io/docs/reference/access-authn-authz/rbac/
* https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/

## Extras

```shell
USER_NAME=DevDan
KUBECONFIG=./DevDan-kubeconfig
CLUSTER=kubernetes

kubectl config set-cluster $CLUSTER \
  --kubeconfig=$KUBECONFIG  \
  --server=https://10.132.0.14:6443 \
  --certificate-authority=$(base64 -w 0 /etc/kubernetes/pki/ca.crt)

kubectl config set-credentials $USER_NAME \
  --kubeconfig=$KUBECONFIG \
  --client-certificate=$(base64 -w 0 $USER_NAME.crt) \
  --client-key=$(base64 -w 0 $USER_NAME.key)

kubectl config set-context $USER_NAME-context \
  --kubeconfig=$KUBECONFIG \
  --cluster=$CLUSTER \
  --namespace=development \
  --user=$USER_NAME
```
