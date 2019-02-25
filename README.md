from [carlessanagustin](https://github.com/carlessanagustin)

# Kubernetes The Hard Way

* Run everything...

```shell
cd lab
./kubernetes-the-hard-way.sh
```

* Clean up the mess...

```shell
cd lab
./kubernetes-the-hard-way_clean-up.sh
```

THANK YOU kelseyhightower! GREAT TUTORIAL!

## Added examples

1. [ConfigMap examples](extras/configmap.md)


---

from [kelseyhightower](https://github.com/kelseyhightower)

# Kubernetes The Hard Way

This tutorial walks you through setting up Kubernetes the hard way. This guide is not for people looking for a fully automated command to bring up a Kubernetes cluster. If that's you then check out [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine), or the [Getting Started Guides](http://kubernetes.io/docs/getting-started-guides/).

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

> The results of this tutorial should not be viewed as production ready, and may receive limited support from the community, but don't let that stop you from learning!

## Target Audience

The target audience for this tutorial is someone planning to support a production Kubernetes cluster and wants to understand how everything fits together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.12.0
* [containerd Container Runtime](https://github.com/containerd/containerd) 1.2.0-rc.0
* [gVisor](https://github.com/google/gvisor) 50c283b9f56bb7200938d9e207355f05f79f0d17
* [CNI Container Networking](https://github.com/containernetworking/cni) 0.6.0
* [etcd](https://github.com/coreos/etcd) v3.3.9
* [CoreDNS](https://github.com/coredns/coredns) v1.2.2

## Labs

This tutorial assumes you have access to the [Google Cloud Platform](https://cloud.google.com). While GCP is used for basic infrastructure requirements the lessons learned in this tutorial can be applied to other platforms.

1. [Prerequisites](docs/01-prerequisites.md)
1. [Installing the Client Tools](docs/02-client-tools.md)
1. [Provisioning Compute Resources](docs/03-compute-resources.md)
1. [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)
1. [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)
1. [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)
1. [Bootstrapping the etcd Cluster](docs/07-bootstrapping-etcd.md)
1. [Bootstrapping the Kubernetes Control Plane](docs/08-bootstrapping-kubernetes-controllers.md)
1. [Bootstrapping the Kubernetes Worker Nodes](docs/09-bootstrapping-kubernetes-workers.md)
1. [Configuring kubectl for Remote Access](docs/10-configuring-kubectl.md)
1. [Provisioning Pod Network Routes](docs/11-pod-network-routes.md)
1. [Deploying the DNS Cluster Add-on](docs/12-dns-addon.md)
1. [Smoke Test](docs/13-smoke-test.md)
1. [Cleaning Up](docs/14-cleanup.md)
