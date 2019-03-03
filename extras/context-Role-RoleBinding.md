# Authentication and Authorization

* user setup

```shell
USER_NAME=DevDan
CERTS_DIR=/home/$USER_NAME
sudo useradd -m -d $CERTS_DIR -s /bin/bash $USER_NAME
sudo passwd $USER_NAME
sudo cp /etc/kubernetes/pki/ca.crt $CERTS_DIR
sudo cp /etc/kubernetes/pki/ca.key $CERTS_DIR
```

* change user

```shell
su - $USER_NAME
USER_NAME=DevDan
CERTS_DIR=/home/$USER_NAME
NAMESPACE=development
CLUSTER=kubernetes
SERVER=https://34.76.29.72:6443
# OR kubectl cluster-info | grep master | cut -d" " -f 6
```

* certificates

```shell
openssl genrsa -out $USER_NAME.key 2048

openssl req -new \
  -key $USER_NAME.key -out $USER_NAME.csr \
  -subj "/CN=$USER_NAME/O=development"

sudo openssl x509 -req -in $USER_NAME.csr \
  -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial -out $USER_NAME.crt -days 3650
```

* kubeconfig

```shell
kubectl config set-cluster $CLUSTER \
  --server=$SERVER \
  --certificate-authority=$CERTS_DIR/ca.crt

kubectl config set-credentials $USER_NAME \
  --client-certificate=$CERTS_DIR/$USER_NAME.crt \
  --client-key=$CERTS_DIR/$USER_NAME.key

kubectl config set-context $USER_NAME-context \
  --cluster=$CLUSTER \
  --namespace=$NAMESPACE \
  --user=$USER_NAME
```

* test: `kubectl --context=DevDan-context get pods`
* error right? continue...

```shell
kubectl create ns development
kubectl create ns production
cat << EOF | kubectl create -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer-role
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
  name: developer-role
  apiGroup: ""
EOF
kubectl --context=DevDan-context get pods
```
## Delete settings

```shell
kubectl config unset contexts.DevDan-context
kubectl config unset users.DevDan
```

## Documentation

* https://kubernetes.io/docs/reference/access-authn-authz/rbac/
* https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
