locals {
  ssh_public_key = file(var.ssh_public_key_path)
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = var.resource_group
  virtual_network_name = var.vpc
}

resource "azurerm_public_ip" "pip" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group

  allocation_method = "Static"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface" "nic" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name      = var.name
    subnet_id = data.azurerm_subnet.subnet.id

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_linux_virtual_machine" "machine" {
  count = var.image.os == "windows" ? 0 : 1

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.size

  admin_username                  = "adminuser"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "adminuser"
    public_key = local.ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "random_string" "windows_admin_password" {
  count  = var.image.os == "windows" ? 1 : 0
  length = 32
}

resource "azurerm_windows_virtual_machine" "machine" {
  count = var.image.os == "windows" ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  size                = var.size

  computer_name = length(var.name) > 15 ? join("-", [
    substr(var.name, 0, 9),
    substr(sha256(substr(var.name, 10, -1)), 0, 5)
  ]) : var.name

  admin_username = "adminuser"
  admin_password = random_string.windows_admin_password[0].result

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  virtual_machine = var.image.os == "windows" ? azurerm_windows_virtual_machine.machine[0] : azurerm_linux_virtual_machine.machine[0]
}