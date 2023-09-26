# Apps

This [Terraform](https://www.terraform.io/) module creates Fleet Bundles on a local / management cluster.

To use this module, ensure that your exported `KUBECONFIG` environment variable points to the local cluster that is running Rancher / Fleet.

> **Note**: If you do not have a Rancher / Fleet instance running, please see the [`rancher` module](../rancher).

## Getting Started

Once you have configured your environment to point into the Rancher / Fleet cluster, (run `kubectl get nodes` to confirm this) this Terraform module will automatically take care of creating the necessary `fleet.cattle.io/v1alpha1` Bundle objects in the local cluster, provisioning the nodes using Terraform on Azure, and running the registration commands to create a custom cluster for you.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/rancher_apps init

# Change the following variable to the cluster name you want to deploy these apps onto
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
export TF_VAR_cluster="clippy-test"
terraform -chdir=terraform/rancher_apps apply
```

This command will deploy Fleet bundles onto the local cluster in the `fleet-default` namespace (or `fleet-local` if the cluster is `local`) corresponding to the apps you intended to deploy.

For example, to deploy the [`windows-webserver` chart](../../charts/windows-webserver), run the following:

```bash
export TF_VAR_cluster="clippy-test"
terraform -chdir=terraform/rancher_apps apply -var-file="examples/windows_webserver.tfvars"
```

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/rancher_apps output
```

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/rancher_apps destroy
```

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
