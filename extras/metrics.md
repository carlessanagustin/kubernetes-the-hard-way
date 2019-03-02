
* `git clone https://github.com/kubernetes-incubator/metrics-server.git`
* @metrics-server/deploy/1.8+/metrics-server-deployment.yaml
```yaml
spec:
  template:
    spec:
      containers:
        command:
        - /metrics-server
        - --kubelet-insecure-tls
```
* apply: `kubectl create -f metrics-server/deploy/1.8+/`
