module "resource_group" {
  source = "../resource_group"

  resource_group = var.name
  location       = var.location
}

module "network" {
  source = "../network"

  resource_group = var.name
  location       = var.location

  type          = var.network.type
  address_space = var.network.address_space
  airgap        = var.network.airgap
  open_ports    = var.network.open_ports
  peers         = var.active_directory != null ? { "${var.active_directory.name}" = {} } : {}
  dns_servers   = var.active_directory != null ? [var.active_directory.ip_address] : null

  depends_on = [
    module.resource_group
  ]
}

module "storage_account" {
  source = "../storage_account"

  resource_group = var.name
  location       = var.location

  storage_account = substr(sha256(var.name), 0, 20)

  depends_on = [
    module.resource_group
  ]
}

locals {
  // See https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets
  num_azure_reserved_private_ip_addresses = 3
}

module "vms" {
  for_each = {
    for i, server in var.servers : server.name => merge(server, {
      private_ip_address = cidrhost(one(module.network.network.subnets[server.subnet].address_prefixes), i + local.num_azure_reserved_private_ip_addresses + 1)
    })
  }

  source = "../vm"

  resource_group = module.resource_group.resource_group.name
  location       = var.location

  vpc                = module.network.network.vpc.name
  subnet             = module.network.network.subnets[each.value.subnet].name
  private_ip_address = each.value.private_ip_address
  dns_servers        = module.network.network.vpc.dns_servers

  storage_account = module.storage_account.storage.account.name

  active_directory = each.value.domain_join ? var.active_directory : null

  name                = each.key
  ssh_public_key_path = var.ssh_public_key_path
  image               = each.value.image
  scripts             = each.value.scripts

  depends_on = [
    module.resource_group,
    module.network,
    module.storage_account
  ]
}

locals {
  machines = {
    for k, v in module.vms : k => v.machine
  }
  debug = element([
    // All of them should be the same
    for k, v in module.vms : v.debug
  ], 0)
}

output "machines" {
  value = local.machines
}

output "debug" {
  value = local.debug
}

output "network" {
  value = module.network.network
}
