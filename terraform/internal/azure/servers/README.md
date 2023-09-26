# Azure Servers Terraform

This [Terraform](https://www.terraform.io/) module spins up all the necessary Azure resources to spin up a set of servers.

> **Note**: Users **cannot use or run this Terraform module standalone** since it does not contain a provider block for the [Azure Resource Manager Terraform provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest).
>
> This is intentionally done since Terraform [does not support including provider blocks in modules called by other modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

## Static Private IP Allocation

This module computes static IP addresses to assign to the provisioned servers by using the index of server in the provided `servers` variable as the host's number (plus 4 for the three reserved IP addresses in Azure environments for any subnet).

For example, the module would assign the five servers listed below the following IP addresses:

```yaml
servers:
  - name: server-1 # EXPECT: 10.0.0.0/8 + 3 reserved ips + 1 + 0 = 10.0.0.4
    subnet: subnet-a # ASSUME: 10.0.0.0/8
  - name: server-2 # EXPECT: 10.0.0.0/8 + 3 reserved ips + 1 + 1 = 10.0.0.5
    subnet: subnet-a # ASSUME: 10.0.0.0/8
  - name: server-3 # EXPECT: 10.0.1.0/8 + 3 reserved ips + 1 + 2 = 10.0.1.6
    subnet: subnet-b # ASSUME: 10.0.1.0/8
  - name: server-4 # EXPECT: 10.0.1.0/8 + 3 reserved ips + 1 + 3 = 10.0.1.7
    subnet: subnet-b # ASSUME: 10.0.1.0/8
  - name: server-5 # EXPECT: 10.0.2.0/8 + 3 reserved ips + 1 + 2 = 10.0.2.8
    subnet: subnet-c # ASSUME: 10.0.2.0/8
```

> **Note**: There are two caveats to this system of static IP assignment:
>
> 1. By design, there is an artificial limit on the number of assignable IP addresses. For example, with the subnets listed above, the largest number of supported hosts is **2^8 - 3 = 253 hosts**, since `10.0.X.257` is invalid and `10.0.1.1` would fall outside the range `10.0.0.0/8`. Better indexing logic could fix this (contributions are welcome!)
> 2. Changes in the order of the VMs provided to this module can result in invalid modifications of static IP addresses that were already assigned to another VM. This is okay since the intent of this module is for **testing setups**, not for **long-standing setups**, as indicated in the disclaimer below.

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
