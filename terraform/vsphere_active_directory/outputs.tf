locals {
  integrations_directory = "dist/active_directory"
  setup_integration_cmd = <<-EOT
      [[ -d ${local.integrations_directory} ]] && rm -rf ${local.integrations_directory}; mkdir -p ${local.integrations_directory}; ${join("'type C:\\etc\\rancher-dev\\active_directory.tar.gz'", matchkeys(split("'",
  replace(module.server.vms[0].machine.ssh_command, " -t ", " ")
), [true, false, true], [true]))} 2>/dev/null | tar -xvzf - -C ${local.integrations_directory}
      EOT

active_directory_integration = {
  name                = var.name
  domain_name         = local.active_directory_fqdn
  domain_netbios_name = local.active_directory_netbios_name
  ip_address          = module.server.vms[0].machine.public_ip
}
}

output "active_directory" {
  value = {
    active_directory_ip       = module.server.vms[0].machine.public_ip
    active_directory_domain   = local.active_directory_fqdn
    active_directory_password = local.active_directory_password
    active_directory_standard_users = [
      for v in local.standard_users : <<-EOT
        user: ${local.active_directory_netbios_name}\${v.name}
        password: ${v.password}
        EOT
    ]
    active_directory_gmsas = local.gmsas
  }
}

output "setup_integration" {
  value = local.setup_integration_cmd
}

output "setup_terraform" {
  value = <<-EOT
    -var=active_directory=${jsonencode(local.active_directory_integration)}
    EOT
}

output "debug" {
  value = "while(1){Get-ChildItem \"C:\\etc\\rancher-dev\\cluster\" -Filter \"*.log\" | sort-object -Property LastWriteTime |  select -last 1 | Get-Content; sleep 5; clear}"
}