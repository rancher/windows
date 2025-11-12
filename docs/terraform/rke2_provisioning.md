# Setting up a Rancher environment for testing RKE2 Windows custom clusters

To set up an environment to test provisioning RKE2 Windows custom clusters in Rancher, you can take the following steps.

## Initial Setup

Initialize the Terraform modules used in this guide:

```bash
terraform -chdir=terraform/vsphere_rke2_cluster init
```

> **Note**: Windows requires an RSA-based SSH key pair.

### Connecting to vSphere

The Terraform modules used in this guide assume that the user has access to a vSphere environment and has permissions to provision VMs. vSphere credentials will need to be specified when creating new `tfvars` files.

### Provision a Rancher instance

You will need to provision a Rancher instance manually before creating a custom rke2 cluster using this automation. Once you have provisioned a Rancher instance, grab the `KUBECONFIG` to the local cluster from the Rancher UI instead and set your `KUBECONFIG` file accordingly.

> **Note**: Once done, verify that you can access the local cluster by running a command like `kubectl get nodes`.

### Create an RKE2 Cluster

To provision a cluster, create a copy of the relevant `tfvarsexample` file for your described configuration and populate the relevant fields with your credentials. Then, run the following Terraform command at the root of this repository to create a [vSphere RKE2 Custom Windows cluster on your Rancher setup](../../terraform/vsphere_rke2_cluster/):

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/vsphere_rke2_cluster apply -var-file="examples/simple-cluster.tfvars" -var="name=${TF_NAME_PREFIX}-cluster"
```

> **Note**: If you do this in a separate console, make sure you also set the `KUBECONFIG` environment variable to the downloaded `KUBECONFIG` in this console.
