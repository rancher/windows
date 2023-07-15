# Azure Docker Rancher

This [Terraform](https://www.terraform.io/) module creates a Rancher Docker Install instance in Azure using Terraform.

## Hosting Rancher at a DigitalOcean DNS **(for Rancher Developers)**

If you supply `-var="create_record=true"` to your Terraform commands, this module will automatically create a DigitalOcean DNS record for the domain `cp-dev.rancher.space` that will point to your Rancher.

By default, this DNS record will be `${TF_VAR_name}-rancher.cp-dev.rancher.space`.

To use this feature, please make sure that you have ran `export DO_ACCESS_KEY=<your-do-token>` so that this module can pick it up and point the DNS record to your Rancher instance's IP, regardless of your infrastructure provider.

## Getting Started

You can use this module to create an instance of Rancher hosted by Azure.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/azure_docker_rancher init

# Change the following variable to the Rancher name you desire
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
# Note: Required for the name provided to this module to end with -rancher
export TF_VAR_name="clippy-test-rancher"

terraform -chdir=terraform/azure_docker_rancher apply
```

This command will spin up a **Azure Docker install of Rancher**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/azure_docker_rancher output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto the host for easy access.
>
> It also assumes the same private key path without the `.pub` prefix is the private key path for the SSH commands contained within the module's output.

## Upgrading Rancher

You have two choices when executing upgrades of this Rancher setup.

### In-Place Upgrade

This is the default behavior. On modifying the Rancher version, Terraform will apply a script that performs an in-place migration by stopping the container, creating a volume from it, and starting a new container based on that same volume.

Since Rancher's Docker image uses an embedded k3s server, this will allow the newly upgraded Rancher to pick up from there with minimal downtime while keeping the local cluster intact.

### Replace

To wipe out and replace the local cluster on the next run, provide `-var="replace=true"`. When set, Terraform will destroy the previous container and create a new one without preserving any volumes. Once performed, this action is irreversible; you cannot get your old local cluster back.

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/azure_docker_rancher destroy
```

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
