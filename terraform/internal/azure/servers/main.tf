module "resource_group" {
  source = "../resource_group"

  resource_group = var.name
  location       = var.location
}

module "network" {
  source = "../rancher/network"

  resource_group = var.name
  location       = var.location

  type       = var.network.type
  airgap     = var.network.airgap
  open_ports = var.network.open_ports

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

module "vms" {
  for_each = {
    for server in var.servers : server.name => server
  }

  source = "../vm"

  resource_group = module.resource_group.resource_group.name
  location       = var.location

  vpc    = module.network.network.vpc.name
  subnet = module.network.network.subnets["external"].name

  storage_account = module.storage_account.storage.account.name

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
}

output "machines" {
  value = local.machines
}