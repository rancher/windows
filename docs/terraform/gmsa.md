# Setting up a Rancher environment for testing gMSA

To set up an environment to test Rancher gMSA features, you can take the following steps.

## Initial Setup

Initialize the Terraform modules used in this guide:

```bash
terraform -chdir=terraform/vsphere_active_directory init

terraform -chdir=terraform/vsphere_rke2_cluster init
```

> **Note**: Windows requires an RSA-based SSH key pair.

### Connecting to vSphere

The Terraform modules used in this guide assume that the user has access to a vSphere instance which they can deploy VMs to.

### Provision an Active Directory instance

To provision an [Active Directory Instance](../../terraform/vsphere_active_directory) in vSphere, first make a copy of `terraform/vsphere_active_directory/examples/simple_gmsa.tfvarsexample` and populate the relevant values fields for your vSphere environment. Then run,

```bash

terraform -chdir=terraform/vsphere_active_directory apply -var-file="examples/simple_gmsa.tfvars"
```

### Ensure Active Directory is ready to go

Once the Terraform module finishes provisioning your Active Directory server, it may take some time for your Active Directory instance to be fully functional.

To check whether all steps are complete, you can SSH onto the Windows host using the command provided in the output (which may also be pending for some time) and run the following command on a `powershell` console:

```powershell
Get-ScheduledTask -TaskPath "\Rancher\Terraform\"
```

If all you see is `entrypoint.ps1` registered, all tasks have completed and the Active Directory instance should be ready to use.

### Collect the output of the Active Directory module

In the output of the Active Directory module, you will see two important outputs for this guide:

1. `setup_terraform`: This contains the command line arguments you should pass into all other vsphere based modules (i.e. `vsphere_rke2_cluster` in this guide) to automatically set up certain qualities such as DNS Server configuration, and domain joining operations.
2. `setup_integration`: This contains a set of commands that you can be run on your local computer to obtain the GUID and SID required for the gMSA solution.

This guide will reference these outputs later, so make sure you keep track of them. You can always get their output by running the following command:

```bash
terraform -chdir=terraform/vsphere_active_directory output
```

### Provision a Rancher instance

In order to create a custom rke2 cluster using this automation, you must already have a Rancher instance provisioned and ready to use. Grab the `KUBECONFIG` to the local cluster from the Rancher UI and set your `KUBECONFIG` file accordingly.

> **Note**: Once done, verify that you can access the local cluster by running a command like `kubectl get nodes`.

### Setup Active Directory integration

Run the following one-line command to execute a script outputted by the Active Directory module that extracts files from the Active Directory instance:

```bash
setup_active_directory_integration=$(terraform -chdir=terraform/vsphere_active_directory output -raw setup_integration)

bash <<TFOUTPUT
${setup_active_directory_integration}
TFOUTPUT
```

This command pulls `values.json` from the server and places the contents into `dist/active_directory` locally.

Once you run it, it will create `dist/active_directory/values.json`. This corresponds to a `values.json` for the [`windows-ad-setup`](../../charts/windows-ad-setup) chart, as well as the fields required for creating `GMSACredentialSpec` custom resource.


### Create a RKE2 Cluster

To provision a cluster, run the following Terraform command at the root of this repository to create a [vSphere RKE2 Custom Windows cluster on your Rancher setup](../../terraform/vsphere_rke2_cluster/):

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/vsphere_rke2_cluster apply -var-file="examples/simple-cluster.tfvars" -var="name=${TF_NAME_PREFIX}-cluster"
```

> **Note**: If you do this in a separate console, make sure you also set the `KUBECONFIG` environment variable to the downloaded `KUBECONFIG` in this console.


### Install the Rancher gMSA Solution

Now that you have provisioned a rke2 cluster in the same vSphere environment as your Active Directory Instance, you can proceed to install the [Rancher gMSA Plugin Solution](https://github.com/rancher/rancher-plugin-gmsa).
