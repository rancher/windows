## rancher
---

This [Terraform](https://www.terraform.io/) module creates a Rancher instance using Terraform.

### Getting Started

You can use this module to create an instance of Rancher hosted by a given cloud provider.

To do so, simply run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/rancher init

# Modify the following name to change it to the cluster name you desire

# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.

export TF_VAR_name="clippy-test"

terraform -chdir=terraform/rancher apply
```

This command should prompt you to provide the Rancher name and will default to spinning up a **Azure Docker install of Rancher**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (this will also be outputted at the end of the `terraform apply` operation):

```bash
terraform -chdir=terraform/rancher output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto the host for easy access.
>
> It also assumes that the private key can be found at the same path without the `.pub` prefix for the SSH commands that are emitted in the module's output.

### Cleaning up

Once you are done:
```bash
terraform -chdir=terraform/rancher destroy
```

### Upgrading Rancher

To trigger the module to upgrade Rancher, simply use the Azure CLI to delete the VM extension with the following command:

```bash
# Assuming TF_VAR_name was set in an above step
export TF_VAR_name=clippy-test

az vm extension delete --resource-group=${TF_VAR_name}-rancher --vm-name=${TF_VAR_name}-rancher-docker --name ${TF_VAR_name}-rancher-docker
```

Then re-run the `terraform apply` command with your new Rancher version!

```bash
export NEW_RANCHER_VERSION=2.7.3

terraform -chdir=terraform/rancher apply -var="rancher_version=${NEW_RANCHER_VERSION}"
```

### Hosting Rancher at a DNS **(for Rancher Developers only)**

If you supply `-var="create_record=true"` to your Terraform commands, this module will automatically create a DigitalOcean DNSrecord for the domain `cp-dev.rancher.space` that will point to your Rancher.

By default, this DNS record will be `${TF_VAR_name}-rancher.cp-dev.rancher.space`.

To use this feature, please make sure that you have ran `export DO_ACCESS_KEY=<your-do-token>` so that this module can pick it up and point the DNS record to your Rancher instance's IP, regardless of what infrastructure it was hosted on.

### State of Support

Currently, this module only supports provisioning **Docker installs** in **Azure**.
