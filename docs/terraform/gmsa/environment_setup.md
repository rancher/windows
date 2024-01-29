# Setting up a Rancher environment for testing gMSA

To set up an environment to test Rancher gMSA features, you can take the following steps.

## Initial Setup

Initialize all the Terraform modules used in this guide:

```bash
terraform -chdir=terraform/azure_docker_rancher init

terraform -chdir=terraform/azure_active_directory init

terraform -chdir=terraform/azure_rke2_cluster init
```

> **Note**: Windows requires an RSA-based SSH key pair.

### Connecting to Azure (and DigitalOcean)

The Terraform modules used in this guide assume that the user has already authenticated their current machine to Azure by following the guidance of the [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

If you plan to use the [`azure_docker_rancher`](../../../terraform/azure_docker_rancher) module with `-var-file="examples/dev.tfvars"` or `-var="create_record=true"`, you will need to export an environment variable called `DO_ACCESS_KEY` containing a [DigitalOcean Access Key](https://docs.digitalocean.com/glossary/access-key/) that corresponds to the Rancher Engineering DigitalOcean account (which has the `cp-dev.rancher.space` DNS domain). **This is optional.**

### Provision an Active Directory instance

To provision an Active Directory instance, run the following Terraform command at the root of this repository to create an [Azure Active Directory installation](../../../terraform/azure_active_directory):

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/azure_active_directory apply -var="name=${TF_NAME_PREFIX}-ad"
```

> **Note**: You can do this in parallel with the previous two steps.

### Ensure Active Directory is ready to go

Once the Terraform module finishes provisioning your Active Directory server, it may take some time for your Active Directory instance to be fully functional.

To check whether all steps are complete, you can SSH onto the Windows host using the command provided in the output (which may also be pending for some time) and run the following command on a `powershell` console:

```powershell
Get-ScheduledTask -TaskPath "\Rancher\Terraform\"
```

If all you see is `entrypoint.ps1` registered, all tasks have completed and the Active Directory instance should be ready to use.

### Collect the output of the Active Directory module

In the output of the Active Directory module, you will see two important outputs for this guide:

1. `setup_terraform`: This contains the command line arguments you should pass into all other Azure-based modules (i.e. `azure_rke2_cluster` and `azure_docker_rancher` in this guide) to automatically set up certain qualities such as VPC peering, DNS Server configuration, and domain joining operations.
2. `setup_integration`: This contains a **required** script that you must run on your local computer before executing the `azure_rke2_cluster` module since you need it to install the `windows-ad-setup` chart.

This guide will reference these outputs later, so make sure you keep track of them. You can always get their output by running the following command:

```bash
terraform -chdir=terraform/azure_active_directory output
```

### Provision a Rancher instance

To provision a Rancher instance, run the following Terraform command at the root of this repository to create an [Azure Docker-based Rancher installation](../../../terraform/azure_docker_rancher):

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

### Setup Active Directory integration

Run the following one-line command to execute a script outputted by the Active Directory module that extracts files from the Active Directory instance:

```bash
setup_active_directory_integration=$(terraform -chdir=terraform/azure_active_directory output -raw setup_integration)

bash <<TFOUTPUT
${setup_active_directory_integration}
TFOUTPUT
```

This command pulls `active_directory.tar.gz` from the server and decompresses the contents into `dist/active_directory` locally.

Once you run it, it should create `dist/active_directory/values.json`. This corresponds to a `values.json` for the [`windows-ad-setup`](../../../charts/windows-ad-setup) chart.

> **Note**: This chart automatically handles creating `GMSACredentialSpecs` and creating an CCG Impersonation Account Secret in the cluster. The `values.json` emitted corresponds to the values specified for gMSA accounts specified in the Terraform values used to provision your Active Directory instance.

### Create an RKE2 Cluster

To provision a cluster, run the following Terraform command at the root of this repository to create an [Azure RKE2 Custom Windows cluster on your Rancher setup](../../../terraform/azure_rke2_cluster/):

```bash
TF_NAME_PREFIX="clippy-test"

setup_active_directory_terraform_integration=$(terraform -chdir=terraform/azure_active_directory output -raw setup_terraform)

terraform -chdir=terraform/azure_rke2_cluster apply -var-file="examples/gmsa.tfvars" -var="name=${TF_NAME_PREFIX}-cluster" ${setup_active_directory_terraform_integration}
```

> **Note**: If you do this in a separate console, make sure you also set the `KUBECONFIG` environment variable to the downloaded `KUBECONFIG` in this console.

On creating this RKE2 cluster, you should automatically see Bundles created in the local cluster, which will instruct Fleet to deploy the manifests for `cert-manager-crd`, `cert-manager`, `rancher-gmsa-webhook-crd`, `rancher-gmsa-webhook`, `windows-ad-setup`, and `windows-gmsa-webserver` onto the cluster.

To check the status of these bundles, run the following command:

```bash
kubectl get bundles -n fleet-default
```

You will also see that the Windows host(s) have already joined the Active Directory domain and should have permissions to use gMSAs.

> **Note**: Like above, make sure the Windows hosts have finished running all steps by checking the Scheduled Tasks before executing any checks.

To verify this, log onto the Windows hosts and run the following commands:

```powershell
# This should spawn a new shell for User1
# Required since the default adminuser is not logged into AD
runas /user:ad\User1 powershell

# When prompted, type in the default password: p@ssw0rd (or whatever you configured it to be)

# On the new powershell window, run the following commmands

# This should install some utility commands we'll use below
Install-WindowsFeature "RSAT-AD-Powershell"

# Verifies that the host can assume the gMSA
Test-AdServiceAccount "GMSA1"
```

> **Note**: You will not be able to see this result over SSH due to some permissions issues. Make sure you run this after you RDP onto the host using the outputted `.rdp` file and opening up a `powershell` session that is running as an administrator.

You can also run this on the Pod created by the `windows-gmsa-webserver` chart to double check that gMSA works as expected:

```powershell
# This should install some utility commands we'll use below
Install-WindowsFeature "RSAT-AD-Powershell"

# Verifies that the host can assume the gMSA
Test-AdServiceAccount "GMSA1"

# Should return something like "user manager\containeradministrator"
whoami

# Should return "gmsa1$@clippy-test-ad.ad.com"
whoami /UPN
```
