# Provisioning V2

Provisioning V2 is the set of controllers embedded into Rancher alongside [CAPI](./capi/README.md) that implement its [RKE2](https://docs.rke2.io/) / [k3s](https://k3s.io/) provisioning solution.

> **Note**: If you do not have familiarity with Cluster API (CAPI), it is highly recommended you read the [docs](./capi/README.md) on it before reading this document.

In Provisioning V2, Rancher directly embeds the upstream CAPI controllers into Rancher.

Then, it defines a set of Provisioning V2's controllers that implement [all of the providers that CAPI supports](./capi/terminology.md) and adds additional functionality that offers advantages over existing vanilla CAPI-provider solutions, such as providing support for the following features.

## Declarative Cluster Creation

Instead of running `clusterctl generate cluster` with command-line arguments and piping the output to `kubectl apply`, Rancher defines two custom resource definitions for creating clusters:
1. An `<Infrastructure>Config`
    - Also known as a **node template / machine pool configuration** for a particular infrastructure (like `DigitalOcean`)
    - Embeds the configuration that would be reflected in the `<Infrastructure>MachineTemplate`
    - Includes options that affect Kubernetes-distribution-level fields, such as whether this is an `etcd` / `controlplane` / `worker` node
    - Includes options that affect how the nodes in this pool are provisioned, such as whether to drain before delete, how to execute rolling updates, etc.
2. A `provisioning.cattle.io` Cluster
    - Embeds one or more `<Infrastructure>Configs` under its `.spec.rkeConfig.machinePools`
    - Embeds the desired configuration of [RKE2](https://docs.rke2.io/) / [k3s](https://k3s.io/) under the other `.spec.rkeConfig.*` fields

On simply creating a `provisioning.cattle.io` Cluster that has a valid Machine Pool configuration, all the other CAPI resources that would be contained in the manifest are created, updated, and removed along with it.

## Generic Machine Provider

Unlike most other CAPI Machine Providers, Rancher implements a **generic Machine Provider** that supports deploying infrastructure to any of the providers of infrastructures that have [Node Drivers](https://github.com/rancher/machine/tree/master/drivers) supported by [`rancher/machine`](./repositories.md#rancher-machine).

This provider supports:

1. Dynamically creating and implementing CRDs for `<Infrastructure>Config`s, `<Infrastructure>MachineTemplate`s, and `<Infrastructure>Machine`s on registering a new Node Driver

2. Running provisioning `Jobs` that execute [`rancher/machine`](./machine.md) to provision and bootstrap new servers

3. Supporting SSHing onto provisioned hosts after creation using host SSH keys returned by the provisioning `Job`

For more information, please see the [docs](./generic_machine_provider.md).

## System Agent

Instead of bootstrapping nodes directly with a Kubernetes distribution, Provisioning V2 bootstraps nodes with [System Agent](./system_agent.md), a daemon that can watch for Machine Plans and execute them on the host on Rancher's behalf.

While the machine plan's initial purpose is to install a Kubernetes distribution via a script provided by a [System Agent Installer](./system_agent_installer.md) image, it can continuously receive updates, which allows Rancher to uniquely support in-place upgrades of Kubernetes components on existing nodes. This cannot be done in most CAPI providers today.

For more information, please see the [docs](./system_agent.md).

## Supporting Airgap

An "airgapped" cluster is a cluster that is not advertised or accessible to **incoming** connections from the external world, primarily for security considerations.

To support generating a `KUBECONFIG` that can be used to send requests to this airgapped cluster, Rancher deploys a component (`cluster-agent`) onto the downstream cluster that contains a **reverse tunnel client** powered by a [`rancher/remotedialer`](https://github.com/rancher/remotedialer), a Layer 4 TCP Remote Tunnel Dialer.

On the downstream cluster being fully provisioned, this deployed client registers with Rancher running in the local / management cluster (which hosts a **reverse tunnel server** at a registration endpoint in its API).

On a downstream cluster registering with Rancher, Rancher can expose an endpoint that allows access to the downstream API provided that a user has a valid **Rancher authentication token** that grants it permission to access the downstream cluster by impersonating some user in that cluster.

This endpoint and the user's Rancher authentication token are then directly used to define `KUBECONFIG` that the user can use to communicate with the downstream, airgapped cluster via Rancher.