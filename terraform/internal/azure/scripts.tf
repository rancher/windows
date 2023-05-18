resource "random_string" "storage_account_name" {
  length  = 15
  special = false
  upper   = false
}

resource "azurerm_storage_account" "scripts" {
  name                = random_string.storage_account_name.result
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "scripts" {
  for_each = local.virtual_machines

  name                 = "${local.prefix}-${each.key}"
  storage_account_name = azurerm_storage_account.scripts.name
}

locals {
  generated_storage_containers = zipmap(
    keys(local.virtual_machines),
    values(azurerm_storage_container.scripts)
  )
}

locals {
  boot_script_blobs = merge([
    for k, v in local.virtual_machines : {
      for i in range(0, length(local.virtual_machines[k].boot_scripts)) : "${k}-boot-script-${i}.${local.virtual_machines[k].image.os == "windows" ? "ps1" : "sh"}" => {
        storage_container_name = local.generated_storage_containers[k].name
        source_content         = local.virtual_machines[k].boot_scripts[i]
      }
    }
  ]...)

  script_blobs = merge([
    for k, v in local.virtual_machines : {
      for i in range(0, length(local.virtual_machines[k].scripts)) : "${k}-script-${i}.${local.virtual_machines[k].image.os == "windows" ? "ps1" : "sh"}" => {
        storage_container_name = local.generated_storage_containers[k].name
        source_content         = local.virtual_machines[k].scripts[i]
      }
    }
  ]...)

  registration_blobs = {
    for k, v in local.virtual_machines :
    "${k}-register.${v.image.os == "windows" ? "ps1" : "sh"}" => merge(v, {
      storage_container_name = local.generated_storage_containers[k].name
      source_content         = v.registration_script != null ? v.registration_script : "echo \"Nothing to do.\""
    })
  }
}

resource "azurerm_storage_blob" "boot_scripts" {
  for_each = local.boot_script_blobs

  name                   = each.key
  storage_account_name   = azurerm_storage_account.scripts.name
  storage_container_name = each.value.storage_container_name
  type                   = "Block"
  source_content         = each.value.source_content
}

resource "azurerm_storage_blob" "registration_script" {
  for_each = local.registration_blobs

  name                   = each.key
  storage_account_name   = azurerm_storage_account.scripts.name
  storage_container_name = each.value.storage_container_name
  type                   = "Block"
  source_content         = each.value.source_content
}

resource "azurerm_storage_blob" "scripts" {
  for_each = local.script_blobs

  name                   = each.key
  storage_account_name   = azurerm_storage_account.scripts.name
  storage_container_name = each.value.storage_container_name
  type                   = "Block"
  source_content         = each.value.source_content
}

locals {
  generated_boot_storage_blobs = zipmap(
    concat(
      keys(local.boot_script_blobs),
    ),
    concat(
      values(azurerm_storage_blob.boot_scripts),
    )
  )

  generated_storage_blobs = zipmap(
    concat(
      keys(local.registration_blobs),
      keys(local.script_blobs)
    ),
    concat(
      values(azurerm_storage_blob.registration_script),
      values(azurerm_storage_blob.scripts)
    )
  )

  generated_boot_storage_blobs_by_container = {
    for containerk, containerv in local.generated_storage_containers : containerk => [
      for blobk, blobv in local.generated_boot_storage_blobs :
      blobv if blobv.storage_container_name == containerv.name
    ]
  }

  generated_storage_blobs_by_container = {
    for containerk, containerv in local.generated_storage_containers : containerk => [
      for blobk, blobv in local.generated_storage_blobs :
      blobv if blobv.storage_container_name == containerv.name
    ]
  }
}

locals {
  extensions = {
    for k, v in local.virtual_machines : k => {
      virtual_machine_id   = local.generated_virtual_machines[k].id
      storage_account_name = azurerm_storage_account.scripts.name
      storage_account_key  = azurerm_storage_account.scripts.primary_access_key
      boot_file_uris       = [for k, v in local.generated_boot_storage_blobs_by_container[k] : v.url]
      file_uris            = [for k, v in local.generated_storage_blobs_by_container[k] : v.url]
      command_hash = substr(sha256(join("\n", concat(
        [for blobk, blobv in local.boot_script_blobs : blobv.source_content if blobv.storage_container_name == local.generated_storage_containers[k].name],
        [for blobk, blobv in local.registration_blobs : blobv.source_content if blobv.storage_container_name == local.generated_storage_containers[k].name],
        [for blobk, blobv in local.script_blobs : blobv.source_content if blobv.storage_container_name == local.generated_storage_containers[k].name],
        v.image.os == "windows" ? ["${file("${path.module}/files/scheduled_task.ps1.tftpl")}"] : []
      ))), 0, 10)
    }
  }

  linux_extensions   = { for k, v in local.extensions : k => v if local.virtual_machines[k].image.os == "linux" }
  windows_extensions = { for k, v in local.extensions : k => v if local.virtual_machines[k].image.os == "windows" }
}

resource "azurerm_virtual_machine_extension" "linux_bootstrap" {
  for_each = local.linux_extensions

  name = "${local.prefix}-${each.key}-${each.value.command_hash}"

  virtual_machine_id = each.value.virtual_machine_id

  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = jsonencode({
    storageAccountName = each.value.storage_account_name
    storageAccountKey  = each.value.storage_account_key
    fileUris           = concat(each.value.boot_file_uris, each.value.file_uris)
    commandToExecute = join("&& ", [
      for file_uri in concat(each.value.boot_file_uris, each.value.file_uris) :
      format(
        "./%s",
        element(split("/", file_uri), length(split("/", file_uri)) - 1)
      )
    ])
  })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_machine_extension" "windows_bootstrap" {
  for_each = local.windows_extensions

  name = "${local.prefix}-${each.key}-${each.value.command_hash}"

  virtual_machine_id = each.value.virtual_machine_id

  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = jsonencode({
    storageAccountName = each.value.storage_account_name
    storageAccountKey  = each.value.storage_account_key
    fileUris           = concat(each.value.boot_file_uris, each.value.file_uris)
    commandToExecute = format("powershell -EncodedCommand \"%s\"",
      textencodebase64(
        templatefile("${path.module}/files/scheduled_task.ps1.tftpl", {
          scripts = join(",", [
            for file_path in [for file_uri in each.value.file_uris : element(split("/", file_uri), length(split("/", file_uri)) - 1)] :
            format("\"%s\"", file_path)
          ])
          boot_scripts = join(",", [
            for file_path in [for file_uri in each.value.boot_file_uris : element(split("/", file_uri), length(split("/", file_uri)) - 1)] :
            format("\"%s\"", file_path)
          ])
        })
      , "UTF-16LE")
    )
  })

  lifecycle {
    ignore_changes = [tags]
  }
}

