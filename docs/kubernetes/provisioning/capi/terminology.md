# Terminology

## Cluster API (CAPI)

[Cluster API (CAPI)](https://cluster-api.sigs.k8s.io/introduction.html) is a declarative API for provisioning and managing Kubernetes clusters.

Once CAPI is installed, users are expected to use [`clusterctl`](https://cluster-api.sigs.k8s.io/clusterctl/overview.html), a command line tool that supports commands like:
- `clusterctl init` to install the CAPI and CAPI Provider components that listen to CAPI and CAPI Provider CRDs
- `clusterctl generate cluster` to create the Kubernetes manifest that defines a CAPI Cluster, which consists of CAPI and CAPI Provider CRDs
- `clusterctl get kubeconfig` to get the `KUBECONFIG` of a CAPI-provisioned cluster to be able to communicate with it

## CAPI Provider

CAPI Providers are sets of controllers that are implemented by third-parties (i.e. AWS, Azure, Rancher, etc.) that provision infrastructure on CAPI's behalf.

These controllers register their own Custom Resource Definitions (CRDs), which allow users to create provider-specific Custom Resources (CRs) to manage their infrastructure.

For more information on how providers work, please read the [docs](./providers.md).

## (Cluster) Infrastructure Provider

A [Cluster Infrastructure Provider](https://cluster-api.sigs.k8s.io/developer/providers/cluster-infrastructure.html) is the **first** provider that gets called by the series of hand-offs from CAPI.

This provider is expected to implement the following CRD:
- `<Infrastructure>Cluster`: referenced by the `.spec.infrastructureRef` of a CAPI `Cluster` CR

On seeing a `<Infrastructure>Cluster` (i.e. `AWSCluster`) for the first time, a Cluster Infrastructure Provider is supposed to create and manage any of the **cluster-level** infrastructure components, such as a cluser's Subnet(s), Network Security Group(s), etc. that would need to be created before provisioning any machines.

> **Note**: As a point of clarification, Rancher's Cluster Infrastructure Provider's CRD is called an `RKECluster` since it is used as the generic Cluster Infrastructure CR for multiple infrastructure providers, although in theory Rancher should be having `DigitalOceanCluster`s or `LinodeCluster`s instead.
>
> This is because Rancher today does not support creating or managing **cluster-level infrastructure components** (which would normally be infrastructure-provider-specific) on behalf of downstream clusters.

Then, once the downstream cluster's API is accessible, the Cluster Infrastructure Provider is supposed to fill in the `<Infrastructure>Cluster` with the controlplane endpoint that can be used by `clusterctl` to access the cluster's Kubernetes API; this is then copied over to the CAPI `Cluster` CR along with some other status fields.

## Bootstrap Provider

A [Bootstrap Provider](https://cluster-api.sigs.k8s.io/developer/providers/bootstrap.html) is the **second** provider that gets called by the series of hand-offs from CAPI.

This provider is expected to implement the following CRDs:
- `<Distribution>Bootstrap`: referenced by the `.spec.bootstrap.ConfigRef` of a CAPI `Machine` CR
- `<Distribution>BootstrapTemplate`: referenced by the `.spec.bootstrap.ConfigRef` of a CAPI `MachineDeployment` or `MachineSet` CR

On seeing a `<Distribution>Bootstrap` (i.e. `RKEBootstrap`), the Bootstrap Provider is expected to create a **Machine Bootstrap Secret** that is referenced by the `<Distribution>Bootstrap` under `.status.dataSecretName`.

This **Machine Bootstrap Secret** is expected to contain a script (i.e. "bootstrap data") that should be run on each provisioned machine before marking it as ready; on successfully running the script, the machine is expected to have the relevant Kubernetes components onto the node for a given **Kubernetes distribution (i.e. kubeAdm, RKE, k3s/RKE2)**.

> **Note**: A point of clarification is that the Bootstrap Provider is not involved in actually running the script to bootstrap a machine.
>
> Running the script defined by the bootstrap provider falls under the purview of the [Machine Infrastructure Provider](#machine-infrastructure-provider).

## Machine (Infrastructure) Provider

A Machine Provider (also known as a [Machine Infrastructure Provider](https://cluster-api.sigs.k8s.io/developer/providers/machine-infrastructure.html)) is the **third** provider that gets called by the series of hand-offs from CAPI.

Machine Providers are expected to implement the following CRDs:
- `<Infrastructure>Machine`: referenced by the `.spec.infrastructureRef` of a CAPI `Machine` CR
- `<Infrastructure>MachineTemplate`: referenced by the `.spec.infrastructureRef` of a CAPI `MachineSet` or `MachineDeployment` CR

On seeing the creation of an `InfrastructureMachine`, a Machine Provider is responsible for **provisioning the physical server** from a provider of infrastructure (such as AWS, Azure, DigitalOcean, etc. as listed [here](https://cluster-api.sigs.k8s.io/user/quick-start.html#initialization-for-common-providers)) and **running a bootstrap script on the provisioned machine** (provided by the [Bootstrap Provider](#bootstrap-provider) via the **Machine Bootstrap Secret**).

The bootstrap script is typically run on the provisioned machine by providing the bootstrap data from the **Machine Bootstrap Secret** as `cloud-init` configuration; if `cloud-init` is not available, it's expected to be directly run on the machine via `ssh` after provisioning it.

> **Note**: What is [`cloud-init`](https://cloud-init.io/)?
>
> Also known as "user data", it's generally used as a standard for providing a script that should be run on provisioned infrastructure, usually supported by most major cloud providers.

## Control Plane Provider

A [Control Plane Provider](https://cluster-api.sigs.k8s.io/developer/architecture/controllers/control-plane.html) is the **fourth** provider that gets called by the series of hand-offs from CAPI.

Control Plane Providers are expected to implement the following CRD:

- `<Distribution>ControlPlane`: referenced by the `.spec.controlPlaneRef` of a CAPI `Cluster` CR. This contains the configuration of the cluster's controlplane, but is only used by CAPI to copy over status values


On seeing a `<Distribution>ControlPlane` and a set of `Machine`s that are Ready, a control plane provider has a couple of jobs:
- Initializing the control plane by managing the set of `Machine`s designated as control plane nodes and installing the controlplane components (`etcd`, `kube-api-server`, `kube-controller-manager`, `kube-scheduler`) and other optional services (`cloud-controller-manager`, `coredns` / `kubedns`, `kube-proxy`, etc.) onto it
- Generating cluster certificates if they don't exist
- Keeping track of the state of the controlplane across all nodes that comprise it
- Joining new nodes onto the existing cluster's controlplane
- Creating / managing a `KUBECONFIG` that can be used to access the cluster's Kubernetes API

Once the bootstrap provider has finished what it needs to do, the downstream cluster is expected to be fully provisioned; you can then run a `clusterctl` command to get the `KUBECONFIG` of your newly provisioned cluster.