locals {
  scripts = concat(
    var.image.os == "windows" ? [
      # Add SSH support for Windows
      templatefile("${path.module}/files/install_ssh.ps1", {}),
      templatefile("${path.module}/files/start_ssh.ps1", {
        ssh_public_key = trim(local.ssh_public_key, "\n")
      })
    ] : [],
    var.image.os == "windows" && var.active_directory != null ? [
      templatefile("${path.module}/files/ad_verify_dns.ps1", {
        domain_name = var.active_directory.domain_name
      }),
      templatefile("${path.module}/files/ad_verify_reverse_dns.ps1", {
        domain_ip = var.active_directory.ip_address
      }),
      templatefile("${path.module}/files/ad_domain_join.ps1", {
        domain_name               = var.active_directory.domain_name
        domain_netbios_name       = var.active_directory.domain_netbios_name
        machine_username          = "adminuser"
        machine_password          = random_string.windows_admin_password[0].result
        active_directory_username = var.active_directory.join_credentials.username
        active_directory_password = var.active_directory.join_credentials.password
        # The assumption here is that the Active Directory instance should exist in a
        # network that this VM has access to (i.e. the network this VM exists within
        # should be peered with the AD network) and the Active Directory instance should
        # have an IP of the format 10.X.Y.Z, where X, Y, and Z can be any number from 0-255.
        # This is where the network prefix length of 8 bits * 3 spaces comes from.
        network_prefix_length = 8 * 3
      })
    ] : [],
    var.scripts
  )

  script_extension = var.image.os == "windows" ? "ps1" : "sh"

  user_scripts = {
    for i, script in local.scripts :
    format("bootstrap-%s.%s",
      i,
      local.script_extension
    ) => script
  }

  script_blobs = merge(var.image.os == "windows" ? {
    "add_scheduled_tasks.ps1" = templatefile(
      "${path.module}/files/add_scheduled_tasks.ps1",
      {
        scripts = join(", ", [for k, v in local.user_scripts : "\"${k}\""])
      }
    )
    } : {}, local.user_scripts
  )
}

module "storage_blobs" {
  source = "../storage_blobs"

  resource_group = var.resource_group
  location       = var.location

  storage_account = var.storage_account

  storage_container = "${var.name}-scripts"
  blobs             = local.script_blobs
}

locals {
  extension_meta = var.image.os == "windows" ? {
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
    } : {
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
  }

  extensions = module.storage_blobs.storage.blobs

  command_to_execute = var.image.os == "windows" ? "powershell.exe -File add_scheduled_tasks.ps1" : length(local.script_blobs) > 0 ? join("; ", [for k, v in local.script_blobs : "./${k}"]) : "echo \"Nothing to do.\""

  script_content = join("; ", concat([local.command_to_execute], values(local.script_blobs)))

  extension_name = format(
    "%s-bootstrap-%s",
    var.name,
    substr(sha256(local.script_content), 0, 10)
  )
}

resource "azurerm_virtual_machine_extension" "bootstrap" {
  name = local.extension_name

  virtual_machine_id = local.virtual_machine.id

  publisher            = local.extension_meta.publisher
  type                 = local.extension_meta.type
  type_handler_version = local.extension_meta.type_handler_version

  protected_settings = jsonencode({
    storageAccountName = var.storage_account
    storageAccountKey  = data.azurerm_storage_account.account.primary_access_key
    fileUris           = [for k, v in local.extensions : v.url]
    commandToExecute   = local.command_to_execute
  })

  lifecycle {
    ignore_changes = [tags]
  }
}
