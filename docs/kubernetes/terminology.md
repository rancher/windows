# Terminology

### Kubernetes

Kubernetes is open-source orchestration software for deploying, managing, and scaling distributed "self-contained, mostly-environment-agnostic processes running in a sandbox" (i.e. containers) running on one or more servers (i.e. nodes).

Each server must have some daemon that can run containers (i.e. a **container runtime** like Docker or containerd) installed on them.

In essence, Kubernetes can be thought of as a multi-server equivalent of Docker: whereas executing `docker ps` will list all of the Docker-managed processes (containers) running on your single server, in Kubernetes executing a `kubectl get pods --all-namespaces` will list all of the groups of Kubernetes-managed distributed processes (i.e. pods) running on every server (node) that has registered with the Kubernetes API (i.e. which can be queried using the CLI tool `kubectl`).

> **Note**: A pod in Kubernetes is generally not a single process / container; it is a set of processes / containers that share the same [network namespace](https://man7.org/linux/man-pages/man7/network_namespaces.7.html) and are a **single logical unit**.
>
> To achieve this, Kubernetes typically leverages a single container known as a **pause** container that starts up and pauses forever. This parent container is used to establish the network namespace (the "sandbox" for all child containers) and keep track of all the other processes that are part of a single pod.
>
> This design is why:
>
> - Two containers running in the same pod cannot use the same port and can communicate via `localhost`.
> - Two containers running in the same pod cannot be distributed across hosts.

## Container Runtimes

In order to run Kubernetes, nodes typically need to have a **container runtime** installed.

A container runtime is a piece of software that typically sits as a **daemon** on a host and manages "sandboxed" processes known as **containers**.

Popular container runtimes include:

- [Docker](https://www.docker.com)
- [containerd](https://containerd.io) (which uses runc under the hood)
- [runc](https://github.com/opencontainers/runc)

> **Note**: Some distributions like [RKE2](./rke2.md) or [k3s](./k3s.md) will install the container runtime as part of the bootstrapping process of the Kubernetes [engine](#engines).

## Distributions

A **Kubernetes distribution** is a piece of software that contains pre-built and pre-packaged Kubernetes components.

When a distribution is installed onto a set of servers (a process known as **bootstrapping**), the servers form a Kubernetes cluster.

### What does a distribution contain?

The set of software components installed onto a particular node in Kubernetes from a distribution depends on what **role** the node takes within the cluster.

Generally, there are two roles:

1. **Agent (Worker)**
2. **Server (Controlplane)**

Depending on the distribution that you use, there may also be a third role: **etcd**, which means that the node is part of the [etcd](https://etcd.io) cluster that serves as the **backing database** for the Kubernetes cluster. However, in many distributions this is bundled into the server role.

> **Note**: It is possible for a single **Linux** node to take on all the roles.
>
> As of today, Windows nodes can only take on the agent / worker role, since the [Kubernetes docs](https://kubernetes.io/docs/concepts/windows/intro/#windows-nodes-in-kubernetes) indicate that you can only run the controlplane (server) on Linux nodes.
>
> In mixed OS clusters, you will have at least one Linux node that takes on the server role.
>
> Specifically, every cluster needs at least one controlplane node, an odd number of etcd nodes (to have a quorom for leader election), and at least one worker node to successfully run Kubernetes. 
>
> Please see [Kubernetes's docs on internal components](https://kubernetes.io/docs/concepts/overview/components/) for more information on what these individual processes do on each host.

### Agent / Worker

An **agent** node typically installs two components:

1. `kubelet`: the **container runtime [shim](https://en.wikipedia.org/wiki/Shim_(computing))** that is responsible for querying the API server to watch for pods that have assigned to an agent node. Once it receives a request to create a new pod, `kubelet` is responsible for talking to the underlying container runtime (i.e. Docker, containerd, runc, etc.) to create, recreate, or remove containers from the host accordingly
2. `kube-proxy`: the **network proxy / network rule manager** that is responsible for querying the API server to watch for pods, services, and other resources to manage your node-specific network rules (typically via `iptables` on a Linux host). For example, this component ensures that your node knows to accept and route incoming traffic directed to a pod or service's IP address to the corresponding container running on the node instead of ignoring it, which would be default behavior of any server on seeing traffic from an IP address that is not the node's IP address. It also ensures that outbound traffic is properly sent to the right IP address. **In other words, this is what forms the definition of a Kubernetes cluster network (on a node-level)**.

### Server / Controlplane

A **server** node typically installs four components:

1. `kube-apiserver`: the **API Server** that is responsible for handling all HTTP requests to the [Kubernetes API](https://kubernetes.io/docs/reference/using-api/api-concepts/). This is the component that receives requests from CLI tools like `kubectl` or Kubernetes controllers.
2. `kube-controller-manager`: the **main controller** in charge of managing the lifecycle of default Kubernetes resources such as nodes, pods, deployments, services, serviceaccounts, etc.
3. `kube-scheduler`: the **main container orchestrator** that is responsible for watching pods and nodes and assigning pods to nodes based on topology constraints (nodeSelectors, tolerations, affinity, etc.)
4. `cloud-controller-manager`: the **cloud provider [shim](https://en.wikipedia.org/wiki/Shim_(computing))** that implements cloud-specific control logic

> **Note**: The `cloud-controller-manager` is **optional**; for example, [k3s](https://github.com/k3s-io/k3s?tab=readme-ov-file#what-have-you-removed-from-upstream-kubernetes) omits this component in favor of asking users to install out-of-tree alternatives for each cloud provider.

## Engines

The process of bootstrapping (i.e. installing Kuberenetes components onto a host) a specific Kubernetes distribution is typically handled by an **engine**.

An engine is a **tool** that can be run on a host to install, upgrade, uninstall, or otherwise manage a distribution's components on a host.

> **Note**: Semantically, distribution and engine are often used interchangeably, since every distribution has an engine that can be used to install it. However, it's important to understand the difference since certain distributions like [RKE1](./rke.md) package the [distribution](https://github.com/rancher/hyperkube) and [engine](https://github.com/rancher/rke) as separate components while others like [k3s/RKE2](./rke2.md) package the distribution directly into the engine.

The way these components are managed on a host will differ depending on the distribution. For example, RKE1 manages components as **containers** running on the host's container runtime, whereas RKE2 manages the components as **pods**.

Engines will also take care of installing additional components, such as [network plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins) or [ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers). Some distributions will even install their own **embedded container runtime**, like RKE2 does with containerd.

While the official engine for Kubernetes is [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/), Rancher also supports several engines packaged in [its own distributions](./rancher_distributions.md) that can be used to provision Kubernetes clusters.

### How do engines work?

When creating a new Kubernetes cluster, one of your nodes will be considered the **init** node, which is the first node you run the engine on. This init node must take on the **server** (and etcd) role so that it can establish the Kubernetes API server, set up the backing database (i.e. etcd) to store further transaction, and run the default controllers.

Once that is complete, you add additional worker or other nodes by "installing" Kubernetes on that node with a configuration that points it to the established API Server's endpoint (usually a DNS entry or IP address pointing to the controlplane node at the API Server's port, which is by default `:6443`).

## Provisioners

A **provisioner** is a piece of software that handles provisioning VMs / instances (either in the cloud or on-premise) and runs the boostrapping process for a given distribution using a Kubernetes engine.

This is what [Rancher](https://ranchermanager.docs.rancher.com) does for RKE1 / RKE2 clusters.

> **Note**: Rancher also supports just providing a registration command that you can bootstrap your hosts with (i.e. custom clusters) or adding existing clusters (i.e. imported clusters) to be managed by Rancher.
>
> For more information on this, see the [relevant docs](../general/types_of_rancher_clusters.md).

### k3d

For development environments, [`k3d`](https://k3d.io) is a unique type of provisioner that, unlike most provisioners, runs on a single host.

It does this by treating **containers** on your host as **nodes** in a cluster, which means that it is possible for a developer to have multiple container-based Kubernetes clusters running directly on their machine.

## Managed Kubernetes Providers

Managed Kubernetes Providers are services offered by major cloud providers that entirely abstract away the details of provisioning and maintaining Kubernetes clusters from a user. Examples include:

- [`AKS`](https://docs.microsoft.com/en-us/azure/aks/) (Microsoft Azure)
- [`EKS`](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) (Amazon)
- [`GKE`](https://cloud.google.com/kubernetes-engine/) (Google)

In these types of clusters, you are typically only offered a **limited view** into the cluster by the underlying cloud's distribution.

For example, you may only have access to see worker nodes, not controlplane nodes, although you will be allowed to add additional worker nodes or set up autoscaling.
