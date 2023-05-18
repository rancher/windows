## windows-cluster
---

This [Terraform](https://www.terraform.io/) module creates a downstream Windows clusters provisioned in various cloud providers using Terraform.

To use this module, ensure that your exported `KUBECONFIG` environment variable currently points to the local cluster that is running Rancher.

> **Note**: If you do not currently have a Rancher instance running, please see the [`rancher` module](../rancher).

### Getting Started

Once you have configured your environment to point into the Rancher cluster, (run `kubectl get nodes` to confirm this) this Terraform module will automatically take care of creating the necessary `provisioning.cattle.io/v1` Cluster object in the local cluster, provisioning the nodes using Terraform on your cloud provider, and running the registration commands to create a custom cluster for you. 

To do so, simply run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/windows-cluster init

# Modify the following name to change it to the cluster name you desire

# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.

export TF_VAR_name="clippy-test"

terraform -chdir=terraform/windows-cluster apply
```

This command should prompt you to provide the cluster name and will default to spinning up a custom Windows cluster in Azure with **one Linux server node of all roles** and **one Windows worker node**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto any of the hosts if you need to debug any problems (this will also be outputted at the end of the `terraform apply` operation):

```bash
terraform -chdir=terraform/windows-cluster output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto every host for easy access.
>
> It also assumes that the private key can be found at the same path without the `.pub` prefix for the SSH commands that are emitted in the module's output.

> **Note**: Hosts created by this Terraform module also have common utilities automatically added to it; for example, this module will automatically add `etcdctl` onto Linux etcd nodes, `calicoctl` onto all Linux nodes, etc. It will also automatically configure the `/etc/profile` on Linux hosts (and the environment on Windows hosts) to take the relevant actions, such as setting the `crictl` configuration and other things.

> **Note**: When provisioning Windows hosts, this module will automatically create and drop `.rdp` files in your current working directory for easy access to the Windows host.

### Cleaning up

Once you are done:
```bash
terraform -chdir=terraform/windows-cluster destroy
```

### Spinning up other common setups

To create more complicated clusters, just provide one of the var files under `windows-cluster/examples` as an argument to the `terraform apply` command. 

For example:

```bash
# 1 Linux controlplane/etcd/worker, 2 Windows workers
terraform -chdir=terraform/windows-cluster apply -var-file=examples/multiple_windows_workers.tfvars

# Provision 1 Linux controlplane, 1 Linux etcd, 1 Linux worker, and 1 Windows worker
terraform -chdir=terraform/windows-cluster apply -var-file=examples/dedicated_roles.tfvars

# etc.
```

If you do spin up this type of setup, make sire you also provide the `--var-file` parameter on a destroy!

```bash
terraform -chdir=terraform/windows-cluster destroy -var-file=path/to/var/file
```

### State of Support

Currently, this module only supports provisioning **custom clusters** in **Azure**.

> **Note**: What are the different types of clusters in Rancher?
>
> A **provisioned** cluster is a cluster whose nodes are provisioned by Rancher's built-in machine provider and bootstrapped by Rancher into an RKE2 cluster.
>
> A **custom** cluster is a cluster whose nodes are provisioned externally (in this case, by this Terraform module) and bootstrapped by Rancher into an RKE2 cluster.
>
> An **imported** cluster is a cluster that is provisioned externally entirely; Rancher simply applies a daemon that allows it to communicate with the cluster (i.e. `cattle-cluster-agent`).
>
> Rancher does not support imported Windows clusters (at the time of writing this documentation) but does support custom clusters on any cloud provider.
>
> Rancher does support provisioned clusters, but this Terraform module does not currently support provisioning these types of clusters.