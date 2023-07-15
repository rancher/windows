# cluster

This [Terraform](https://www.terraform.io/) module creates an RKE2 [custom cluster]((../../docs/general/types_of_rancher_clusters.md)) provisioned in Azure and bootstrapped by an existing Rancher instance.

To use this module, ensure that your exported `KUBECONFIG` environment variable points to the local cluster that is running Rancher.

> **Note**: If you do not have a Rancher instance running, please see the [`rancher` module](../rancher).

## Getting Started

Once you have configured your environment to point into the Rancher cluster, (run `kubectl get nodes` to confirm this) this Terraform module will automatically take care of creating the necessary `provisioning.cattle.io/v1` Cluster object in the local cluster, provisioning the nodes using Terraform on Azure, and running the registration commands to create a custom cluster for you.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/azure_rke2_cluster init

# Change the following variable to the cluster name you desire
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
export TF_VAR_name="clippy-test"

terraform -chdir=terraform/azure_rke2_cluster apply
```

This command will spin up a custom Windows cluster in Azure with **one Linux server node of all roles** and **one Windows worker node**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/azure_rke2_cluster output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto every host for easy access.
>
> It also assumes the same private key path without the `.pub` prefix is the private key path for the SSH commands contained within the module's output.
>
> **Note**: Hosts created by this Terraform module also have common utilities automatically added to it; for example, this module will automatically add `etcdctl` onto Linux etcd nodes, `calicoctl` onto all Linux nodes, etc. It will also automatically configure the `/etc/profile` on Linux hosts (and the environment on Windows hosts) to take the relevant actions, such as setting the `crictl` configuration.
>
> **Note**: When provisioning Windows hosts, this module will automatically create and drop `.rdp` files in your current working directory for easy access to the Windows host.

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/azure_rke2_cluster destroy
```

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
