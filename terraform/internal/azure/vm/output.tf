locals {
  vm                     = var.image.os == "windows" ? azurerm_windows_virtual_machine.machine[0] : azurerm_linux_virtual_machine.machine[0]
  windows_admin_password = var.image.os == "windows" ? random_string.windows_admin_password[0].result : ""

  inferred_ssh_private_key_path = trimsuffix(var.ssh_public_key_path, ".pub")

  machine = {
    metadata = {
      name  = local.vm.name
      image = var.image
      size  = local.vm.size
    }
    public_ip              = azurerm_public_ip.pip.ip_address
    windows_admin_password = local.windows_admin_password
    ssh_command = format("ssh -i %s -t %s@%s '%s'",
      local.inferred_ssh_private_key_path,
      local.vm.admin_username,
      azurerm_public_ip.pip.ip_address,
      var.image.os == "linux" ? "sudo su - root" : "powershell"
    )
  }
}

output "machine" {
  value = local.machine
}

output "server" {
  value = {
    subnet                 = var.subnet
    vm                     = local.vm
    windows_admin_password = local.windows_admin_password
  }
}

output "ip" {
  value = azurerm_public_ip.pip
}

resource "local_file" "rdp_file" {
  count = var.image.os == "windows" ? 1 : 0

  content  = <<-EOT
  full address:s:${azurerm_public_ip.pip.ip_address}:3389
  prompt for credentials:i:1
  administrative session:i:1
  EOT
  filename = "${path.cwd}/${var.name}.rdp"
}

