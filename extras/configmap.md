# Kubernetes ConfigMap examples

## 1. from-env-file

* setup ConfigMap

```shell
cat << EOF > vars.env
LALA="my name is mud"
OWOW=fantastic
EOF
kubectl create configmap from-env-file --from-env-file=./vars.env
kubectl get configmaps from-env-file -o yaml > from-env-file.yaml
cat from-env-file.yaml
```

* output:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: from-env-file
  namespace: default
  uid: 9a968243-3868-11e9-92a4-42010a84000e
data:
  LALA: '"my name is mud"'
  OWOW: fantastic
```

* use ConfigMap

```shell
cat << EOF > from-env-file-deploy1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  restartPolicy: Never
  containers:
    - name: test-container1
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: LALA-inside
          valueFrom:
            configMapKeyRef:
              name: from-env-file
              key: LALA
    - name: test-container2
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls -l /shared && cat /shared/LALA && echo" ]
      volumeMounts:
        - name: configmap-volume1
          mountPath: /shared
    - name: test-container3
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls -l /shared && cat /shared/special-path && echo" ]
      volumeMounts:
        - name: configmap-volume2
          mountPath: /shared
  volumes:
    - name: configmap-volume1
      configMap:
        name: from-env-file
    - name: configmap-volume2
      configMap:
        name: from-env-file
        # ONLY: environment variables or key=value
        items:
        - key: OWOW
          path: special-path

EOF
kubectl create -f from-env-file-deploy1.yaml
```

### test

* run `kubectl logs  test-pod  test-container1 | grep -i LALA`
* correct output: `LALA-inside="my name is mud"`
* run `kubectl logs  test-pod  test-container2`
* correct output:

```shell
total 0
lrwxrwxrwx    1 root     root            11 Feb 24 20:30 LALA -> ..data/LALA
lrwxrwxrwx    1 root     root            11 Feb 24 20:30 OWOW -> ..data/OWOW
"my name is mud"
```

* run `kubectl logs  test-pod  test-container3`
* correct output:

```shell
total 0
lrwxrwxrwx    1 root     root            19 Feb 24 20:30 special-path -> ..data/special-path
fantastic
```

* clean up: `kubectl delete pod test-pod && kubectl delete cm from-env-file`

## 2. from-file

* setup ConfigMap

```shell
cat << EOF > vars.conf
LILI: my name is mud
AWAW: fantastic
EOF
kubectl create configmap from-file --from-file=./vars.conf
kubectl get configmaps from-file -o yaml > from-file.yaml
cat from-file.yaml
```

* output:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: from-file
  namespace: default
  uid: 034d866b-386e-11e9-92a4-42010a84000e
data:
  vars.conf: |
    LILI: my name is mud
    AWAW: fantastic
```

* use ConfigMap as Volume

```shell
cat << EOF > from-file-deploy1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  restartPolicy: Never
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls -la /shared && cat /shared/vars.conf" ]
      volumeMounts:
        - name: configmap-volume
          mountPath: /shared
  volumes:
    - name: configmap-volume
      configMap:
        name: from-file
EOF
kubectl create -f from-file-deploy1.yaml
```

* run: `kubectl logs test-pod`
* correct output:

```shell
total 0
lrwxrwxrwx    1 root     root            16 Feb 24 20:40 vars.conf -> ..data/vars.conf
LILI: my name is mud
AWAW: fantastic
```

* clean up: `kubectl delete pod test-pod && kubectl delete cm from-file`

## 3. from-literal

* setup ConfigMap

```shell
kubectl create configmap from-literal --from-literal=GASGAS=1234
kubectl get configmaps from-literal -o yaml > from-literal.yaml
cat from-literal.yaml
```

* output:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: from-literal
  namespace: default
  uid: e3bd6c31-386f-11e9-92a4-42010a84000e
data:
  GASGAS: "1234"
```

```shell
cat << EOF > from-literal-deploy1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  restartPolicy: Never
  containers:
    - name: test-container1
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: GASGAS-inside
          valueFrom:
            configMapKeyRef:
              name: from-literal
              key: GASGAS
    - name: test-container2
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls -l /shared && cat /shared/GASGAS && echo" ]
      volumeMounts:
        - name: configmap-volume
          mountPath: /shared
  volumes:
    - name: configmap-volume
      configMap:
        name: from-literal
EOF
kubectl create -f from-literal-deploy1.yaml
```

* run: `kubectl logs test-pod test-container1 | grep -i GASGAS`
* correct output: `GASGAS-inside=1234`
* run: `kubectl logs test-pod test-container2`
* correct output:

```
total 0
lrwxrwxrwx    1 root     root            13 Feb 24 20:19 GASGAS -> ..data/GASGAS
1234
```

* clean up: `kubectl delete pod test-pod && kubectl delete cm from-literal`

## more information

* https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
