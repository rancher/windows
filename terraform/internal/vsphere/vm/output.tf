locals {
  machine = {
    public_ip = vsphere_virtual_machine.vm.guest_ip_addresses[0]
    ssh_command = format("ssh -t %s@%s '%s'",
      var.connection_details.username,
      vsphere_virtual_machine.vm.guest_ip_addresses[0],
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
      while(1){Get-ChildItem "C:\etc\rancher-dev\cluster" -Filter "*.log" | sort-object -Property LastWriteTime |  select -last 1 | Get-Content; sleep 5; clear}

      EOT
    linux   = <<-EOT
      # Check all stderr logs from initialization scripts
      cat /var/lib/waagent/custom-script/download/*/stderr

      # Check all stdout logs from initialization scripts
      cat /var/lib/waagent/custom-script/download/*/stdout
    EOT
  }
}

output "debug" {
  value = var.image.os == "windows" ? local.debug.windows : local.debug.linux
}

output "machine" {
  value = local.machine
}

resource "local_file" "rdp_file" {
  count = var.image.os == "windows" ? 1 : 0

  content  = <<-EOT

  full address:s:${vsphere_virtual_machine.vm.guest_ip_addresses[0]}:3389
  prompt for credentials:i:1
  administrative session:i:1
  username:s:Administrator
  desktopwidth:i:1920
  desktopheight:i:1080

  EOT
  filename = "${path.cwd}/${var.name}.rdp"
}
