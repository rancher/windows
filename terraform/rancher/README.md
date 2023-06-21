# rancher

This [Terraform](https://www.terraform.io/) module creates a Rancher instance using Terraform.

## Getting Started

You can use this module to create an instance of Rancher hosted by a given cloud provider.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/rancher init

# Change the following variable to the cluster name you desire
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
export TF_VAR_name="clippy-test"

terraform -chdir=terraform/rancher apply
```

This command should prompt you to provide the Rancher name and will default to spinning up a **Azure Docker install of Rancher**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/rancher output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto the host for easy access.
>
> It also assumes the same private key path without the `.pub` prefix is the private key path for the SSH commands contained within the module's output.

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/rancher destroy
```

## Hosting Rancher at a DNS **(for Rancher Developers)**

If you supply `-var="create_record=true"` to your Terraform commands, this module will automatically create a DigitalOcean DNS record for the domain `cp-dev.rancher.space` that will point to your Rancher.

By default, this DNS record will be `${TF_VAR_name}-rancher.cp-dev.rancher.space`.

To use this feature, please make sure that you have ran `export DO_ACCESS_KEY=<your-do-token>` so that this module can pick it up and point the DNS record to your Rancher instance's IP, regardless of your infrastructure provider.

## State of Support

This module supports provisioning **Docker installs** in **Azure**.
