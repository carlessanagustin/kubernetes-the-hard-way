# NFS Persistent Volumes example

* check present status: `kubectl get deploy,pod,pv,pvc -o wide`
* requirements

```shell
NFS_FOLDER=/shared
sudo apt-get update && sudo apt-get install -y nfs-kernel-server
sudo mkdir -p $NFS_FOLDER
sudo bash -c "echo '$NFS_FOLDER    *(rw,sync,no_root_squash,subtree_check)' >> /etc/exports"
sudo exportfs -ra
sudo bash -c "echo 'this is a test' > $NFS_FOLDER/lala"
```

* create

```shell
# A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator.
cat << EOF > pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-1
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: slow
  nfs:
    path: /shared
    server: k8s-master-001
EOF

# A PersistentVolumeClaim (PVC) is a request for storage by a user
cat << EOF > pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-1
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 2Gi
  storageClassName: slow
EOF

cat << EOF > nfs-pod.yaml
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  restartPolicy: Never
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls -l /shared-inside && cat /shared-inside/lala && echo" ]
      volumeMounts:
        - name: myclaim
          mountPath: /shared-inside
  volumes:
    - name: myclaim
      persistentVolumeClaim:
        claimName: pvc-1
EOF

kubectl create -f pv.yaml
kubectl create -f pvc.yaml
kubectl create -f nfs-pod.yaml
```

* clean up

```shell
kubectl delete -f nfs-pod.yaml
kubectl delete -f pvc.yaml
kubectl delete -f pv.yaml
```

* more information: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

## Troubleshooting

* show NFS publications: `showmount -e k8s-master-001`

## ResourceQuota

```shell
# A resource quota provides constraints that limit aggregate resource consumption per namespace.
cat << EOF > rq.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-rq
  namespace: limits
spec:
  hard:
    persistentvolumeclaims: 10
    requests.storage: 500Mi
EOF
```
