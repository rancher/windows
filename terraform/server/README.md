# server

This [Terraform](https://www.terraform.io/) module creates a simple server using Terraform.

## Getting Started

You can use this module to create a simple server hosted by a given cloud provider.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/server init

# Change the following variable to the cluster name you desire
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
export TF_VAR_name="clippy-test"

terraform -chdir=terraform/server apply
```

This command should prompt you to provide a name and will default to spinning up a **Azure Linux server**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/server output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto the host for easy access.
>
> It also assumes the same private key path without the `.pub` prefix is the private key path for the SSH commands contained within the module's output.

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/server destroy
```

## Creating a Windows node

To trigger the module to create a Windows node, use the example from `windows.tfvars`:

```bash
terraform -chdir=terraform/server apply -var-file="examples/windows.tfvars"

terraform -chdir=terraform/server output

terraform -chdir=terraform/server destroy -var-file="examples/windows.tfvars"
```

## State of Support

This module supports provisioning **Linux or Windows servers** in **Azure**.
