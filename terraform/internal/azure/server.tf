locals {
  virtual_machines = { for v in var.servers : v.name => v }

  linux_virtual_machines = {
    for k, v in local.virtual_machines : k => v if v.image.os == "linux"
  }

  windows_virtual_machines = {
    for k, v in local.virtual_machines : k => v if v.image.os == "windows"
  }

  network_interfaces = {
    for k, v in local.virtual_machines :
    k => {
      subnet_id = local.generated_subnets[v.subnet].id
    }
  }
}

resource "azurerm_public_ip" "pips" {
  for_each = local.virtual_machines

  name                = "${local.prefix}-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  generated_public_ips = zipmap(
    keys(local.virtual_machines),
    values(azurerm_public_ip.pips)
  )
}

resource "azurerm_network_interface" "nics" {
  for_each = local.network_interfaces

  name                = "${local.prefix}-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.prefix}-${each.key}"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.generated_public_ips[each.key].id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  generated_network_interfaces = zipmap(
    keys(local.network_interfaces),
    values(azurerm_network_interface.nics)
  )
}

resource "azurerm_linux_virtual_machine" "machines" {
  for_each = local.linux_virtual_machines

  name                = "${local.prefix}-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  network_interface_ids = [local.generated_network_interfaces[each.key].id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = each.value.disk_size_gb
  }

  admin_username                  = "adminuser"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "adminuser"
    public_key = local.ssh_public_key
  }

  size = each.value.size
  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "random_string" "windows_admin_password" {
  count  = length(local.windows_virtual_machines) > 0 ? 1 : 0
  length = 32
}

resource "azurerm_windows_virtual_machine" "machines" {
  for_each = local.windows_virtual_machines

  name = "${local.prefix}-${each.key}"
  computer_name = join("-", [
    substr("${local.prefix}-${each.key}", 0, 9),
    substr(sha256(substr("${local.prefix}-${each.key}", 10, -1)), 0, 5)
  ])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  network_interface_ids = [local.generated_network_interfaces[each.key].id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = each.value.disk_size_gb
  }

  admin_username = "adminuser"
  admin_password = random_string.windows_admin_password[0].result

  size = each.value.size
  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  generated_linux_virtual_machines = zipmap(
    keys(local.linux_virtual_machines),
    values(azurerm_linux_virtual_machine.machines)
  )

  generated_windows_virtual_machines = zipmap(
    keys(local.windows_virtual_machines),
    values(azurerm_windows_virtual_machine.machines)
  )

  generated_virtual_machines = merge(local.generated_linux_virtual_machines, local.generated_windows_virtual_machines)
}

