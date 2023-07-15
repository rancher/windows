locals {
  scripts = concat(
    var.image.os == "windows" ? [
      # Add SSH support for Windows
      <<-EOT
      Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';
      Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;"
      EOT
      ,
      <<-EOT
      Start-Service sshd;
      Set-Service -Name sshd -StartupType 'Automatic';
      Add-Content -Path 'C:\ProgramData\ssh\administrators_authorized_keys' -Value '${local.ssh_public_key}';
      icacls.exe 'C:\ProgramData\ssh\administrators_authorized_keys' /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F';
      Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;"
      EOT
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

  command_to_execute = var.image.os == "windows" ? "powershell.exe -File add_scheduled_tasks.ps1" : length(local.script_blobs) > 0 ? join("&& ", [for k, v in local.script_blobs : "./${k}"]) : "echo \"Nothing to do.\""

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
