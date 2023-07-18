# Azure Resource Group Terraform

This [Terraform](https://www.terraform.io/) module spins up a Resource Group in Azure.

> **Note**: Users **cannot use or run this Terraform module standalone** since it does not contain a provider block for the [Azure Resource Manager Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest).
>
> This is intentionally done since Terraform [does not support including provider blocks in modules called by other modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
