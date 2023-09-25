# Rancher Fleet Bundle Terraform

This [Terraform](https://www.terraform.io/) module creates a `fleet.cattle.io/v1alpha1` Bundle on a local / management cluster.

It supports the following types of applications:

1. A local Helm chart
    1. `path` is a relative or absolute path on the host
    2. `values` is not `null` or `values_file` is not null
2. A remote Helm chart
    1. `path` begins with `http` or `https`
    2. `values` is not `null` or `values_file` is not null
3. A local manifest
    1. `path` is a relative or absolute path on the host
    2. `values` is `null` and `values_file` is null
4. A remote manifest
    1. `path` begins with `http` or `https`
    2. `values` is `null` and `values_file` is null
5. An inline manifest
    1. `manifest` is not `null`

It also supports declaring dependencies on other bundles, which can allow you to schedule dependent applications deployed in a particular order.

See the [`rancher_apps`](../../../../rancher_apps) or [`azure_rke2_cluster`](../../../../azure_rke2_cluster) Terraform module for more examples on its usage.

> **Note**: Users **cannot use or run this Terraform module standalone** since it does not contain a provider block for the [Azure Resource Manager Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest).
>
> This is intentionally done since Terraform [does not support including provider blocks in modules called by other modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
