# Networking In Terraform Modules

## Address Spaces

To support advanced cross-module features such as support for [network peering](https://en.wikipedia.org/wiki/Peering) (required for setups that involve Active Directory), this repository expects that each Terraform module rooted in the [`terraform`](../../terraform) directory that provisions VMs in Azure will claim a **unique address space within `10.0.0.0/24`** in the format `10.X.0.0.16`.

This implies that this repository supports a total of **2^8 = 256 Azure VM Terraform modules** and each Terraform module can assign a max of **2^(8+8) = 65,536** network resources (including those that your cloud provider treats as reserved IP addresses).

### Claimed Address Spaces

Each of the following address spaces is the default address space for the specified Terraform module:

- [`azure_active_directory`](../../terraform/azure_active_directory): `10.0.0.0/16`
- [`azure_docker_rancher`](../../terraform/azure_docker_rancher): `10.1.0.0/16`
- [`azure_rke2_cluster`](../../terraform/azure_rke2_cluster): `10.2.0.0/16`
- [`azure_server`](../../terraform/azure_server): `10.3.0.0/16`

## IP Allocation

Any VM provisioned by a module in this repository will have **static private IP allocation** and **dynamic public IP allocation**.

The Terraform module calculates which static private IP to use based on the address space the VM exists within (i.e. either the virtual network address space or the subnet address space).

This means that adding or removing servers after applying a Terraform module may not be cleanly supported (if such a change would cause the order of the provisioned servers to change in some way).
