# Rancher RKE1 Cluster Terraform

This [Terraform](https://www.terraform.io/) module creates a `management.cattle.io/v3` [custom RKE1 cluster]((../../docs/general/types_of_rancher_clusters.md)) in a Rancher instance.

> **Note**: Users **cannot use or run this Terraform module standalone** since it does not contain a provider block for the [Azure Resource Manager Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest).
>
> This is intentionally done since Terraform [does not support including provider blocks in modules called by other modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
