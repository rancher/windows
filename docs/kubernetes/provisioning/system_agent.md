# System Agent

[`rancher/system-agent`](https://github.com/rancher/system-agent) is a daemon that sits on every host provisioned or bootstrapped (i.e. custom clusters) by Provisioning V2.

This daemon is provided a `KUBECONFIG` that allows it to watch a specific Machine Plan Secret within the local / management cluster, through which it retrieves a "Plan" to be executed. 

> **Note**: In RKE2 Windows only, System Agent is directly embedded in [wins](./wins.md)
>
> This ensures that only a single daemon needs to be installed onto Windows hosts.
>
> Please refer to the docs on [Wins](./wins.md) for more details.

## Why was System Agent built?

System Agent was built to facilitate a unique approach around bootstrapping nodes in a CAPI-provisioned cluster.

### What is bootstrapping?

The term "bootstrapping" comes from the phrase "to pull oneself by one's bootstraps". 

It refers to a self-starting process that continues and grows **without any user input**.

In the case of Kubernetes components installed by Kubernetes distributions, this applies since the Kubernetes components themselves are typically managed by some underlying daemon on the host (i.e. `systemd`, `Docker`, etc.) that differs depending on the Kubernetes distribution you are working with.

Therefore, once installed, the Kubernetes internal components are self-[re]starting processes that are capable of "pulling themselves by their bootstraps".

This is why the process of installing the Kubernetes distribution onto a node is typically referred to as "bootstrapping" a node.

### CAPI's Approach

In upstream CAPI, bootstrapping nodes is only intended as a **one-time** action. Once nodes have been bootstrapped, they must be destroyed and recreated.

This is why:

1. `Machine`s are immutable

2. `MachineDeployment`s **replace** `Machine`s on modifications instead of **re-configuring** existing `Machine`s

3. "Remediation" for failed `MachineHealthChecks` **delete** the unhealthy machine (presumably to be replaced to satisfy the `MachineSet` requirements)

4. "Remediation" for modifications to the cluster's control plane configuration **replaces** existing control plane `Machine`s with newly bootstrapped `Machine`s with the new control plane configuration

Therefore, on performing actions like Kubernetes upgrades, you cannot upgrade your existing node; you must destroy and recreate your node **always**.

### Rancher's Approach

To avoid requiring all upgrades to destroy and recreate nodes, Rancher implements CAPI's Bootstrap Provider to install a **System Agent**.

By having a daemon constantly running on the machine, instead of performing bootstrapping just once, the System Agent can **manage** the host, which allows it to receive user inpute to alter the behavior or configuration of running Kubernetes components **on-demand**.

> **Note**: Just because Rancher manages the Kubernetes Internal Components **does not** mean it is breaking the CAPI Bootstrap Provider contract.
>
> If Rancher stopped managing the Machine the moment is was Ready, it would be identical to any other normal Bootstrap Provider in the upstream CAPI world; it just happens to be able to continue to pass on updates, which is partially only possible due to the highly declarative design of RKE2 / K3s as a Kubernetes distribution.

> **Note**: For those familiar with the analogy, the primary advantage of managing servers as opposed to replacing them is that Rancher supports both users who need to have their provisioned servers treated as "pets" (i.e. hard to replace) as well as those whose servers can be treated as "cattle" (i.e. can be easily swapped).

## How does it work?

System Agent is bootstrapped as a daemon onto host.

It is managed by `systemd` on Linux (or as a [Windows Service](https://learn.microsoft.com/en-us/dotnet/framework/windows-services/introduction-to-windows-service-applications) running within [Wins](./wins.md) on Windows).

> **Note**: Why deploy `rancher/system-agent` as a [systemd](https://systemd.io/) Service?
>
> This ensures that, if `rancher/system-agent` goes down for some reason (i.e. the node is rebooted), it is automatically restarted without any intervention from Rancher's Bootstrap Provider itself.
>
> This is important since, as mentioned before, a Bootstrap Provider is only expected to be involved up till a node is provisioned and added to a Kubernetes cluster; from there, it's not expected that the Bootstrap Provider should do anything for a node that is already provisioned.
>
> The only thing that CAPI supports after a node has been provisioned is `MachineHealthChecks`, which are implemented by CAPI's own controllers, not a provider's controllers.

On bootstrap, the System Agent is given a `KUBECONFIG` that allows it to watch for a **Machine Plan Secret** in the local / management cluster.

The Machine Plan Secret is kept up-to-date by a special set of **RKE Planner** controllers that are part of the Provisioning V2 Control Plane Provider implementation.

By updating the Machine Plan Secret, System Agent is informed about a **Plan** that needs to be executed on the node to reconcile the node against the new cluster configuration.

### Machine Plans

The Machine Plan Secret encodes one or more Machine Plans in `*.plan` file(s) like those found in [the `rancher/system-agent` examples](https://github.com/rancher/system-agent/tree/main/examples). 

The [`applyinator`](https://github.com/rancher/system-agent/tree/main/pkg/applyinator) module contains the logic for executing plans.

Each Machine Plan may contain the following **four** configurations:

1. **Files**: raw files that should be created before instructions are ran.

2. **Probes**: HTTP endpoints that should be queried on a periodic basis to confirm whether the plan was successful. These start after instructions are executed.

3. **One-Time Instructions**: commands that should execute exactly once (uses checksums to avoid re-runs)

4. **Periodic Instructions**: commands that should periodically be re-run

> **Note**: Each instruction is a command (including environment variables and arguments) that should be run on the **host**, not within a container.
>
> Even though System Agent allows you to specify an image for the instruction to use, this image is not actually used; only the files that the image contains are extracted onto the host before running the instruction.
>
> This is why it's common for images provided to System Agent in this way to only be made from [scratch](https://hub.docker.com/_/scratch).

Upon execution (or upon observing changes, like updates to probe status), System Agent reports the observed configuration back to Rancher via the same Machine Plan Secret.
