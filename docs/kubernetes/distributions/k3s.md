# k3s

## What is k3s?

**k3s** is a "minified" / "simplified" Kubernetes distribution that focuses on **ease of deployment** for its use cases.

The engine is packaged as a **single binary** with a simple launcher that is secure by default and has minimal OS dependencies.

k3s is built for use cases including **edge / IoT** and **CI / development** (such as [k3d](https://github.com/k3d-io/k3d)).

### Removal of In-Tree Providers

To keep the binary small, k3s removes **in-tree storage drivers** and **in-tree cloud providers**. This differs from upstream Kubernetes (and from [RKE2](./rke2.md)).

Support for out-of-tree storage drivers (CSI) and out-of-tree cloud providers (CCM) can still be added to a k3s cluster after provisioning.

### Core Features

Unlike other Kubernetes distributions, k3s has a couple of important differences from a **design perspective** that make it unique:

1. For ease of installation, k3s comes pre-packaged with an **embedded container runtime** (containerd and runc). This means that a node that installs k3s does not need to come pre-installed with a container runtime!
2. k3s replaces etcd with a datastore [shim](https://en.wikipedia.org/wiki/Shim_(computing)) called [Kine](https://github.com/k3s-io/kine), which allows it to use [SQLite](https://www.sqlite.org/index.html) as its default backing database. It can use other databases like Postgres and MySQL too.
3. k3s exposes a single **supervisor port** (port 9345) on every server node. On joining the cluster, new server and agent nodes establish a websocket connection with an existing node (often the **init** node). These connections form a sort of ["service mesh"](https://en.wikipedia.org/wiki/Service_mesh) that exists independently and as a precursor to the creation of the actual Kubernetes network established by the cluster's [Container Network Interface (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) plugin. As a result, kubelet is now able to talk to the API server via this connection, which allows k3s to schedule the internal Kubernetes components as **Pods** managed by Kubernetes itself.
4. To deploy its add-on components, k3s pre-packages a `HelmChart` controller ([helm-controller](https://github.com/k3s-io/helm-controller)). This controller is used to deploy all add-on components as [Helm charts](https://helm.sh/), which makes it easy to install, upgrade, and configure these components in a decalarative fashion.

### Add-On Components

To set up networking, k3s deploys the following components as Helm charts:

- A layer 3 network fabric ([flannel](https://github.com/flannel-io/flannel) CNI)
- An in-cluster DNS solution ([CoreDNS](https://coredns.io))
- A `LoadBalancer` controller ([ServiceLB](https://github.com/k3s-io/klipper-lb))
- An `Ingress` controller ([Traefik](https://containo.us/traefik))
- A `NetworkPolicy` controller ([KubeRouter](https://www.kube-router.io/))

For other advanced features, it deploys the following additional components as Helm charts:

- An local storage volume provisioner ([local-path-provisioner](https://github.com/rancher/local-path-provisioner))
- A service that implements the [Kubernetes Metrics API](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#metrics-api) ([metrics-server](https://github.com/kubernetes-sigs/metrics-server))

### Additional Tooling

k3s automatically adds user-space binaries ([iptables/nftables, ebtables, ethtool, socat, etc.](https://github.com/k3s-io/k3s-root)) onto each host.

### Does k3s support Windows?

As of June 2024, k3s does not support adding Windows nodes.

However, a different "flavor" of k3s called [RKE2](https://docs.rke2.io/) does support Windows nodes. Windows users are recommended to use RKE2 instead of k3s.

For more information about RKE2, please see the [docs](./rke2.md).
