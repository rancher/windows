module "network" {
  source = "../../rancher/network"

  type          = var.type
  address_space = var.address_space
  airgap        = var.airgap
  open_ports    = var.open_ports
}

locals {
  prefix = var.resource_group

  vpc     = module.network.vpc
  subnets = module.network.subnets
  rules = [
    for i, rule in module.network.rules :
    {
      name        = "${rule.action}-${rule.name}"
      description = "${rule.description}"
      access      = title(rule.action)
      direction   = title(rule.direction)

      source_port_range      = "*"
      destination_port_range = rule.port_range

      source_address_prefix        = rule.from == ["*"] ? "*" : null
      destination_address_prefix   = rule.to == ["*"] ? "*" : null
      source_address_prefixes      = rule.from != ["*"] ? rule.from : null
      destination_address_prefixes = rule.to != ["*"] ? rule.to : null

      protocol = title(rule.protocol)
      priority = 4096 - i
    }
  ]
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.prefix
  location            = var.location
  resource_group_name = var.resource_group

  address_space = [local.vpc.address_space]
  dns_servers   = var.dns_servers

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.prefix
  location            = var.location
  resource_group_name = var.resource_group

  dynamic "security_rule" {
    for_each = local.rules

    content {
      name                         = security_rule.value.name
      description                  = security_rule.value.description
      access                       = security_rule.value.access
      direction                    = security_rule.value.direction
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_address_prefix        = security_rule.value.source_address_prefix
      destination_address_prefix   = security_rule.value.destination_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefixes = security_rule.value.destination_address_prefixes
      protocol                     = security_rule.value.protocol
      priority                     = security_rule.value.priority
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = local.subnets

  name                 = "${local.prefix}-${each.key}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group

  address_prefixes = [each.value]
}

locals {
  generated_subnets = zipmap(keys(local.subnets), values(azurerm_subnet.subnets))
}

resource "azurerm_subnet_network_security_group_association" "subnet_to_nsg" {
  for_each = local.subnets

  subnet_id                 = local.generated_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

output "network" {
  value = {
    vpc                    = azurerm_virtual_network.vnet
    network_security_group = azurerm_network_security_group.nsg
    subnets                = local.generated_subnets
  }
}
