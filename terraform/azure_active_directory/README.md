# Azure Active Directory

This [Terraform](https://www.terraform.io/) module creates an Active Directory domain controller server in Azure using Terraform and sets up private DNS pointing to the Active Directory instance within its virtual network.

## How to Use This Module

To use this module with other modules in this repository, the output of this module will provide command line options in the form of `-var="active_directory=<some-json>"`.

These command line options will configure the other Azure-based modules in this repository (i.e. [`azure_rke2_cluster`](../azure_rke2_cluster) and [`azure_server`](../azure_server)) to set up the following automatically:

1. **VPC Peering**: This will create a peering relationship between the virtual network created by this module and the virtual network created by the other module to allow the VMs to communicate with the Active Directory instance using local network protocols.
2. **DNS Server Configuration**: This will configure the other virtual network to treat this Active Directory instance as its primary DNS server.
3. **Domain Join**: This will configure the VMs themselves to identify the Active Directory instance as their DNS server and execute scripts that will domain join them to this Active Directory instance. This will allow those VMs to also automatically assume the roles of gMSAs created by this module.

> **Note**: If you are planning to provision an Active Directory setup, make sure to provision this module before provisioning other modules.
>
> If you provision other modules first and something is wrong, your nodes may require a reboot to be able to reach out to the Active Directory instance at its private DNS.

## Using this module with [`azure_rke2_cluster`](../azure_rke2_cluster)

Before you provide the `active_directory` command line arguments outputted by this module to provision the cluster, you will need to run the script in `setup_integration` locally to emit a `values.yaml` file for the `windows-ad-setup` chart if you are planning to deploy that chart, such as if you are using [`azure_rke2_cluster/examples/gmsa.tfvars`](../azure_rke2_cluster/examples/gmsa.tfvars).

## Using this module with [`azure_docker_rancher`](../azure_docker_rancher/)

To test Rancher's own integration with Active Directory as a basis for logging in users, run the script in `setup_rancher_integration` locally to apply the manifest outputted by this module.

## Getting Started

You can use this module to create an instance of Active Directory hosted by Azure.

To do so, run the following command **from the root of this Git repository**:

```bash
# Run the following command the first time that you initialize this module to pull in the relevant providers.

terraform -chdir=terraform/azure_active_directory init

# Change the following variable to the Rancher name you desire
# Note: It's recommended that you should use your own name instead of "clippy" so that you can identify the resources you create in your cloud provider, should the Terraform module fail for some reason and require manual cleanup of resources.
# Note: Required for the name provided to this module to end with -ad
export TF_VAR_name="clippy-test-ad"

terraform -chdir=terraform/azure_active_directory apply
```

This command will spin up a **Azure Docker install of Rancher**.

Once it has finished running, you can run the following command to get the relevant commands you need to get onto the host if you need to debug any problems (the `terraform apply` operation will output this):

```bash
terraform -chdir=terraform/azure_active_directory output
```

> **Note**: By default, this module will automatically mount the SSH public key found at `~/.ssh/id_rsa.pub` (configurable by passing in `-var ssh_public_key_path=path/to/my/key` to the `terraform apply` command) onto the host for easy access.
>
> It also assumes the same private key path without the `.pub` prefix is the private key path for the SSH commands contained within the module's output.

## Verifying that Active Directory is ready

Once the `terraform apply` exits, you will still have to wait for some of the jobs it kicked off to finish running for Active Directory to be fully set up.

To check if all the jobs have finished, run the following command:

```powershell
Get-ScheduledTask -TaskPath \Rancher\Terraform\
```

All you should see is `entrypoint.ps1`, which indicates that all tasks are complete.

Once all tasks are complete, the computer will automatically restart and it may take some time for SSH to come back. Till then, you can log into the host using the provided `windows.admin_password` via Remote Desktop.

## Verifying that Active Directory is up and running

Run the following commands once you can access your host via SSH:

```powershell
Get-Service adws,kdc,netlogon,dns
```

All the services here should be have a `Status` of `Running`.

```powershell
$domainController = Get-ADDomainController

# Should be the active directory fqdn
$domainController.Domain

# Should be 389
$domainController.LdapPort

# Should be true
$domainController.Enabled
```

```powershell
$forest = Get-ADForest

# Should be your domain
$forest.Domains

Get-AdUser -Filter "samAccountName -like '*'"
Get-AdGroup -Filter "samAccountName -like '*'"
```

## Cleaning up

To clean up resources:

```bash
terraform -chdir=terraform/azure_active_directory destroy
```

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
