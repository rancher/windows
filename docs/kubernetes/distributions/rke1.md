# RKE1

> **Note**: RKE1 Windows is no longer supported. Please see [SUSE Support's document](https://www.suse.com/support/kb/doc/?id=000020684) on this.
>
> This document exists for posterity to identify and document the design of RKE1 Windows and how to debug it.

## What is RKE1?

RKE1 (Rancher Kubernetes Engine) is a [Kubernetes distribution](./provisioning.md#distributions) offered by Rancher.

While RKE1 used to support adding Windows nodes to create mixed OS clusters with both Windows and Linux nodes, **RKE1 Windows is no longer supported by Rancher**; Rancher supports RKE1 clusters with Linux nodes.

For users who still use Windows nodes on their Kubernetes clusters or for users who would like to migrate to the latest that Rancher has to offer, Rancher has a new offering called [**RKE2**](./rke2.md).

## Why is RKE1 Windows no longer supported?

RKE1 relies on Docker Engine for Windows being installed on a Windows host.

However, upon the [deprecation of Dockershim support in Kubernetes 1.20](https://techcommunity.microsoft.com/t5/apps-on-azure-blog/dockershim-deprecation-and-aks/ba-p/3055902) (removed in Kubernetes 1.24), Docker Engine could no longer be used as a container runtime for newer Kubernetes versions.

Since RKE2 uses containerd instead of Docker Engine (which is supported), it can still support Windows hosts.

> **Note**: While it is possible to deploy  [`cri-dockerd`](https://github.com/Mirantis/cri-dockerd), a [shim](https://en.wikipedia.org/wiki/Shim_(computing)) that allows Kubernetes to communicate with Docker via the expected [Container Runtime Interface (CRI)](https://kubernetes.io/docs/concepts/architecture/cri/), to use Docker Engine as the container runtime on a Windows host, this conflicts with Microsoft's guidance since Microsoft does not recommend using `cri-dockerd` and has deprecated Docker on Windows hosts; this is the core reason why RKE1 Windows reached End of Life (EOL).

## How does k3s/RKE2 differ from RKE1?

This newer distributions avoid some of the pitfalls baked into the design of RKE1; notable difference include, but are not limited to:

1. RKE1 relies on an **"externally" managed [Docker](https://www.docker.com)** (or Docker Engine) running on the host as the underlying [container runtime](https://opensource.com/article/21/9/container-runtimes), whereas RKE2 provides an **embedded [containerd](https://containerd.io/)** that comes as part of the RKE2 installation process itself. This reduces a lot of user bugs around invalid host [dockerd](https://docs.docker.com/engine/reference/commandline/dockerd/) configurations since RKE2 retains **full control over the configuration of the container runtime** it ships within the RKE2 binary itself.
2. RKE1 has an **imperative** model of installation / upgrade relying on an **external** host (i.e. your computer or the Rancher server) running commands like `rke up` to get the nodes up and running. This requires the external host to be **capable of SSHing into each of the nodes**. RKE2 follows a **declarative** model of installation / upgrades that happens **directly on the host**. To do this, each host registers RKE2 as a **[systemd unit](https://www.digitalocean.com/community/tutorials/what-is-systemd)** that watches for changes to a configuration file to perform configuration updates. This makes RKE2 more suitable for declarative provisioning solutions like **booting up nodes via [cloud-init](https://cloud-init.io) or [Terraform](https://www.terraform.io)**.
3. RKE1 makes **Docker client calls** to deploy system components (kubelet, kube-proxy, etc.) as **Docker containers**. You can debug RKE1 via commands like `docker ps` or `docker log`. RKE2 deploys system components as **static pods managed by kubelet itself**. You can debug RKE2 via commands like `crictl ps` or `crictl logs` (since containerd is the underlying container runtime for RKE2).
4. RKE1 supports certain CNI plugins (Canal, Flannel, Calico, and Weave), whereas RKE2 supports a different set of CNI plugins (Cilium, Calico, Canal and Multus) for Linux clusters. For Windows clusters, RKE supports Flannel and RKE2 supports Canal.
5. RKE2 introduces the idea of a **supervisor port** (port 9345) that runs on every "server" (controlplane / etcd) node. This port serves as a sort of ["service mesh"](https://en.wikipedia.org/wiki/Service_mesh) / "registration" port that allows new server and agent nodes to establish basic connectivity, often based on the first server node (often referred to as the **init** node). Since this network exists independently and as a precursor to the creation of the actual Kubernetes network established by the cluster's [Container Network Interface (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) plugin, RKE2 can use kubelet (which proxies requests to the API Server via this port) to manage all other Kubernetes components on the host, including the CNI plugin itself (deployed as a [Helm chart](https://helm.sh/) managed by the embedded RKE2 [helm-controller](https://github.com/k3s-io/helm-controller)).
6. As a distribution, RKE2 **natively supports adding Windows nodes**; in RKE1, the provisioner (i.e. **Rancher**) performed this job.

## Debugging RKE1 Windows

## Find the Kubernetes component logs

Grab the Docker logs and see what's going on:

```powershell
# Find the cattle-node-agent container ID via docker ps
$CATTLE_NODE_AGENT_CONTAINER_ID = ""
docker logs $CATTLE_NODE_AGENT_CONTAINER_ID -f

docker logs kubelet -f
docker logs kube-proxy -f
docker logs nginx -f
docker logs service-sidekick -f
```

## Identify host processes managed by wins

Get details about the host processes managed by `wins` (which will always follow the copied binary format, which is the binary name prefixed with `rancher-wins-`):

```powershell
Get-WmiObject Win32_Process -filter "CommandLine LIKE '%rancher-wins-%'"
```

## Clean up any orphaned hosts processes

This is the right thing to do if you see an unauthorized error on renaming an executable in the logs; this indicates that `wins` cannot create the copied version of the binary from the container because an orphaned process is still running the older version of it:

```powershell
Get-WmiObject Win32_Process -filter "CommandLine LIKE '%rancher-wins-%'" | Remove-WmiObject
```
