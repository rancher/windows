# Repositories

Outside of Rancher's codebase, Rancher maintains several independently released components that Provisioning V2 relies on.

## Rancher Machine

`rancher/machine` is a fork of [docker/machine](https://github.com/docker/machine) that Rancher has been maintaining since the upstream repository has been archived.

`rancher/machine` powers provisioning infrastructure across various cloud providers in both Rancher's Provisioning V1 (RKE) and Provisioning V2 (k3s / RKE2) solutions.

It can be used as an independent binary of its own right; each call to `create` like `rancher-machine create -d <driver> <additional-driver-args> <instance-name>` can be used to provision exactly one node on a given infrastructure provider (identified by `<driver>`), given some configuration arguments for the node (identified within the ` <additional-driver-args>`).

For more information on how it is used, please see the Generic Machine Provider [docs](./generic_machine_provider.md).

## System Agent / Wins

[`rancher/system-agent`](https://github.com/rancher/system-agent) is a daemon that sits on every host provisioned or bootstrapped (i.e. custom clusters) by Provisioning V2.

This daemon is provided a `KUBECONFIG` that allows it to watch a specific Machine Plan Secret within the local / management cluster, through which it retrieves a "Plan" to be executed. 

On initialization, the Machine Plan Secret typically starts with a "one time instruction" that installs the distribution (i.e. k3s or RKE2) using file(s) found in a System Agent Installer image.

For more information, please read the [docs](./system_agent.md)

## Wins

[`rancher/wins`](https://github.com/rancher/wins) embeds System Agent and supports additional functionality on Windows hosts.

For more information, please read the [docs](./wins.md).

## System Agent Installer

Rancher maintains two repositories that are System Agent Installers:

1. [`rancher/system-agent-installer-rke2`](https://github.com/rancher/system-agent-installer-rke2) (supports Windows)

2. [`rancher/system-agent-installer-k3s`](https://github.com/rancher/system-agent-installer-k3s) (does not support Windows)

A System Agent Installer is a Docker image that contains a `run.sh` or `run.ps1` that installs a Kubernetes distribution onto a host.

The run file itself typically just runs the underlying `k3s` or `rke2` installation process the same way that users are instructed to do so to manually provision those clusters in the docs.

System Agent Installer images are typically built from [`scratch`](https://hub.docker.com/_/scratch) since they are only pulled by System Agent to extract the files; once extracted, the image is never executed since the command is run on the host.

For more information on how this "one-time instruction" is executed within Provisioning V2, see the [System Agent](./system_agent.md) docs.
