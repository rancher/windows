## vSphere RKE2 Cluster

This module provides automation for creating a rke2 **custom cluster** within a target Rancher Server, automatically handling provisioning and joining an arbitrary number of nodes to the cluster.

## Usage

To use this module, you first must ensure that your exported `KUBECONFIG` environment variable points to a local cluster that is already running Rancher.

Then, copy `examples/simple-cluster.tfvarsexample` and populate the required fields for the given vSphere environment. Add any number of desired nodes to the cluster definition, making sure to pass valid values for the specified VM templates. Finally, run `terraform apply` and pass the `tfvars` file you previously created.

## Other Details

+ Unlike the more general `vsphere_server` package, it is not possible to provision Windows nodes which are joined to an Active Directory domain.
+ It's possible to automatically deploy helm charts to the provisioned clusters. For more details on this is done, refer to `examples/windows_2022_apps.tfvarsexample`

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
