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
    private_ip             = local.virtual_machine.private_ip_address
    windows_admin_password = var.image.os == "linux" ? "" : local.windows_admin_password
    windows_hostname       = var.image.os == "linux" ? "" : local.windows_hostname
    windows_domain         = var.image.os == "linux" ? "" : var.active_directory == null ? "" : var.active_directory.domain_name
    ssh_command = format("ssh -i %s -t %s@%s '%s'",
      local.inferred_ssh_private_key_path,
      local.vm.admin_username,
      azurerm_public_ip.pip.ip_address,
      var.image.os == "linux" ? "sudo su - root" : "powershell"
    )
  }

  debug = {
    windows = <<-EOT
      # Check whether there are any pending initialization scripts
      Get-ScheduledTask -TaskPath "\Rancher\Terraform\"

      # Check the initialization script logs for any errors
      Get-ChildItem "C:\etc\rancher-dev\cluster" -Filter "bootstrap-*.log" | sort | Get-Content
      
      # Get all successful task scheduler events
      Get-WinEvent -FilterXml @"
      <QueryList>
      <Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
      <Select Path="Microsoft-Windows-TaskScheduler/Operational">*[EventData [@Name='TaskSuccessEvent']]</Select>
      </Query>
      </QueryList>
      "@

      # Monitor the initialization scripts. These can take several minutes to complete.
      while(1){Get-ScheduledTask -TaskPath "\Rancher\Terraform\"; sleep 5; clear}

      EOT
    linux   = <<-EOT
      # Check all stderr logs from initialization scripts
      cat /var/lib/waagent/custom-script/download/*/stderr

      # Check all stdout logs from initialization scripts
      cat /var/lib/waagent/custom-script/download/*/stdout
    EOT
  }
}

output "machine" {
  value = local.machine
}

output "debug" {
  value = local.debug
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

