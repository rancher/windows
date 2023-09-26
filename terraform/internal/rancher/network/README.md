# Rancher Networking Rules Terraform

This [Terraform](https://www.terraform.io/) module contains the networking rule templates that provision different types of networks across cloud providers, following guidance from the [Rancher docs](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/installation-requirements/port-requirements).

Primarily, this Terraform module outputs three values:

- **vpc**: An object with the following keys
  - **address_space**: The address space to use for this VPC
- **subnets**: A map with keys corresponding to subnets in the VPC and values corresponding to address spaces for those subnets
- **rules**: A cloud-agnostic specification of networking rules for your VPC, utilizing the address spaces provided for your VPC and subnets above.

## Checking networking rules per template

To see the networking rules per network template, run the following command at the root of this repository:

```bash
NETWORK_TEMPLATE="simple"
# NETWORK_TEMPLATE="rke2-calico"
# NETWORK_TEMPLATE="rke1-flannel"

terraform -chdir=terraform/internal/rancher/network plan --var="type=${NETWORK_TEMPLATE}"
```

## Expectations On Address Spaces

While not explicitly required for this module to function, this module validates that the `address_space` is in the format `10.X.0.0/16`.

This encodes the expectation that all other modules in this repository must have a **unique address space within `10.0.0.0/24`** to instantiate their resources.

This simplifies adding cross-module features such as support for [network peering](https://en.wikipedia.org/wiki/Peering) that is necessary for more complex setups that require that servers share a common network (i.e. Active Directory).

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
