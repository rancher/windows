# Setting up a Rancher environment for testing RKE2 Windows custom clusters

To set up an environment to test provisioning RKE2 Windows custom clusters in Rancher, you can take the following steps.

## Initial Setup

Initialize all the Terraform modules used in this guide:

```bash
terraform -chdir=terraform/azure_docker_rancher init

terraform -chdir=terraform/azure_rke2_cluster init
```

> **Note**: Windows requires an RSA-based SSH key pair.

### Connecting to Azure (and DigitalOcean)

The Terraform modules used in this guide assume that the user has already authenticated their current machine to Azure by following the guidance of the [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

If you plan to use the [`azure_docker_rancher`](../../terraform/azure_docker_rancher) module with `-var-file="examples/dev.tfvars"` or `-var="create_record=true"`, you will need to export an environment variable called `DO_ACCESS_KEY` containing a [DigitalOcean Access Key](https://docs.digitalocean.com/glossary/access-key/) that corresponds to the Rancher Engineering DigitalOcean account (which has the `cp-dev.rancher.space` DNS domain). **This is optional.**

### Provision a Rancher instance

To provision a Rancher instance, run the following Terraform command at the root of this repository to create an [Azure Docker-based Rancher installation](../../terraform/azure_docker_rancher):

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/azure_docker_rancher apply -var="name=${TF_NAME_PREFIX}-rancher"
```

If you would like for your Rancher instance to be accessible via a `*.cp-dev.rancher.space` domain instead of via IP, also provide `-var-file="examples/dev.tfvars"` or `-var="create_record=true"`.

If you already have a Rancher instance up and running, skip to the next step.

### Export the `KUBECONFIG` to the Rancher local cluster

Once you have provisioned a Rancher instance, you can download the `KUBECONFIG` pointing to the Rancher local cluster by running the command provided in the output of the Terraform module referenced above.

This command will download the `KUBECONFIG` into a file like `${TF_NAME_PREFIX}-rancher.kubeconfig` and run `export KUBECONFIG=$(pwd)/${TF_NAME_PREFIX}-rancher.kubeconfig`.

If you are using an existing Rancher setup, grab the `KUBECONFIG` to the local cluster from the Rancher UI instead and set your `KUBECONFIG` file accordingly.

> **Note**: Once done, verify that you can access the local cluster by running a command like `kubectl get nodes`.

### Create an RKE2 Cluster

To provision a cluster, run the following Terraform command at the root of this repository to create an [Azure RKE2 Custom Windows cluster on your Rancher setup](../../terraform/azure_rke2_cluster/):

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/azure_rke2_cluster apply -var-file="examples/windows.tfvars" -var="name=${TF_NAME_PREFIX}-cluster"
```

To provision an Azure RKE2 Custom Linux cluster on your Rancher setup, run the following Terraform command at the root of this repository:

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/azure_rke2_cluster apply -var-file="examples/linux.tfvars" -var="name=${TF_NAME_PREFIX}-cluster"
```

> **Note**: If you do this in a separate console, make sure you also set the `KUBECONFIG` environment variable to the downloaded `KUBECONFIG` in this console.
