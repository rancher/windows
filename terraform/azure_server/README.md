# server

This [Terraform](https://www.terraform.io/) module creates one or more servers in Azure using Terraform.

## Getting Started

You can use this module to create a server in Azure.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/azure_server init

# Change the following variable to the cluster name you desire
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
export TF_VAR_name="clippy-test-server"

terraform -chdir=terraform/azure_server apply
```

This command should prompt you to provide the Rancher name and will spin up an **Azure server**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/azure_server output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto the host for easy access.
>
> It also assumes the same private key path without the `.pub` prefix is the private key path for the SSH commands contained within the module's output.

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/azure_server destroy
```

## Creating a Windows node

To trigger the module to create a Windows node, use the example from `windows.tfvars`:

```bash
terraform -chdir=terraform/azure_server apply -var-file="examples/windows.tfvars"

terraform -chdir=terraform/azure_server output

terraform -chdir=terraform/azure_server destroy -var-file="examples/windows.tfvars"
```

## Creating a Windows node with the Containers feature enabled

Windows Servers do not come configured with support for containerized workloads out of the box; in order for a Windows Server to run containerized workloads, you must install the optional `Containers` feature.

To trigger the module to create a Windows node with the `Containers` feature enabled, use the example from [`examples/windows_2022_containers.tfvars`](./examples/windows_containers.tfvars)

```bash
terraform -chdir=terraform/azure_server apply -var-file="examples/windows_2022_containers.tfvars"

terraform -chdir=terraform/azure_server output

terraform -chdir=terraform/azure_server destroy -var-file="examples/windows_2022_containers.tfvars"
```

> **Note:** The node will be automatically restarted once the Containers feature installs, due to this you should wait about 1-2 minutes after provisioning to register the node.

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
