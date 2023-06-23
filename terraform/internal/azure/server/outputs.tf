locals {
  inferred_ssh_private_key_path = trimsuffix(var.ssh_public_key_path, ".pub")
  windows_password              = length(random_string.windows_admin_password) > 0 ? random_string.windows_admin_password[0].result : ""

  machines = {
    for k, v in local.virtual_machines :
    k => {
      metadata = {
        name          = local.generated_virtual_machines[k].name
        computer_name = lookup(local.generated_virtual_machines[k], "computer_name", null)
        image         = join(":", [v.image.publisher, v.image.offer, v.image.sku, v.image.version])
        size          = v.size
      }
      public_ip = local.generated_public_ips[k].ip_address
      ssh_command = format("ssh -i %s -t %s@%s '%s'",
        local.inferred_ssh_private_key_path,
        local.generated_virtual_machines[k].admin_username,
        local.generated_public_ips[k].ip_address,
        v.image.os == "linux" ? "sudo su - root" : "powershell"
      )
    }
  }
}

output "machines" {
  value = local.machines
}

output "windows_password" {
  value = local.windows_password
}

resource "local_file" "rdp_files" {
  for_each = local.windows_virtual_machines

  content  = <<-EOT
  full address:s:${local.generated_public_ips[each.key].ip_address}:3389
  prompt for credentials:i:1
  administrative session:i:1
  EOT
  filename = "${path.cwd}/${local.prefix}-${each.value.name}.rdp"
}