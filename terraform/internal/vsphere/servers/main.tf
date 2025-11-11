module "vms" {
  for_each = {
    for server in flatten([
      for serv in var.servers : [
        for i in range(serv.replicas) : {
          key    = "${serv.name}-${i}"
          server = serv
          name   = "${serv.name}-replica-${i}"
        }
      ]
    ]) : server.key => server
  }

  source = "../vm"

  connection_details = each.value.server.connection_details == null ? {
    username            = each.value.server.image.os == "windows" ? var.common_connection_details.windows_username : var.common_connection_details.linux_username
    password            = each.value.server.image.os == "windows" ? var.common_connection_details.windows_password : var.common_connection_details.linux_password
    ssh_key_path        = var.common_connection_details.ssh_key_path
    ssh_public_key_path = var.common_connection_details.ssh_public_key_path
    } : {
    username            = each.value.server.connection_details.username != null ? each.value.server.connection_details.username : ""
    password            = each.value.server.connection_details.password != null ? each.value.server.connection_details.password : ""
    ssh_key_path        = each.value.server.connection_details.ssh_key_path != null ? each.value.server.connection_details.ssh_key_path : ""
    ssh_public_key_path = each.value.server.connection_details.ssh_public_key_path != null ? each.value.server.connection_details.ssh_public_key_path : ""
  }

  # VM specific options
  name         = each.value.name
  cpu_count    = each.value.server.cpu_count
  memory_in_mb = each.value.server.memory_in_mb
  disk_size    = each.value.server.disk_size
  guest_id     = each.value.server.guest_id

  image  = each.value.server.image
  folder = each.value.server.folder
  os     = each.value.server.image.os

  # vCenter options
  data_center     = var.data_center
  datastore       = var.datastore
  compute_cluster = var.compute_cluster
  network         = var.network
  resource_pool   = var.resource_pool

  scripts = concat(each.value.server.windows_script_bundle == "debug" ? local.debugScripts : [],
    each.value.server.windows_script_bundle == "dev" ? local.commonDevScripts : [],
    each.value.server.windows_script_bundle == "advancedDev" ? local.advancedDevScripts : [],
    each.value.server.scripts != null ? each.value.server.scripts : [],
    var.active_directory != null && each.value.server.active_directory_credentials != null ? [
      {
        name = "ad_domain_join.ps1"
        content = templatefile("${path.module}/files/ad_domain_join.ps1", {
          domain_name               = var.active_directory.domain_name
          domain_netbios_name       = var.active_directory.domain_netbios_name
          machine_username          = each.value.server.connection_details != null ? each.value.server.connection_details.username : var.common_connection_details.windows_username
          machine_password          = each.value.server.connection_details != null ? each.value.server.connection_details.password : var.common_connection_details.windows_password
          active_directory_username = each.value.server.active_directory_credentials.username
          active_directory_password = each.value.server.active_directory_credentials.password
          active_directory_server   = var.active_directory.ip_address
        })
      }
    ] : [],
    each.value.server.sql_server_configuration != null ? [
      {
        name = "setup_sql.ps1"
        content = templatefile("${path.module}/files/setup_sql.ps1",
          {
            windows_AD_user     = each.value.server.connection_details != null ? each.value.server.connection_details.username : var.common_connection_details.windows_username
            windows_AD_password = each.value.server.active_directory_credentials.password
            windows_AD_domain   = var.active_directory.domain_name
            local_password      = each.value.server.connection_details != null ? each.value.server.connection_details.password : var.common_connection_details.windows_password
          }
        )
      },
      {
        name = "setup_sql_database.ps1"
        content = templatefile("${path.module}/files/setup_sql_database.ps1",
          {
            test_database_name = each.value.server.sql_server_configuration.database_name
            test_table_name    = each.value.server.sql_server_configuration.table_name
        })
      },
      {
        name = "setup_sql_users.ps1"
        content = templatefile("${path.module}/files/setup_sql_users.ps1", {
          test_database_name = each.value.server.sql_server_configuration.database_name,
          ad_net_bios        = var.active_directory.domain_netbios_name,
          test_user_name     = each.value.server.active_directory_credentials.username
        })
      },
      {
        name    = "setup_sql_management_ui.ps1"
        content = file("${path.module}/files/setup_sql_management_ui.ps1")
      }
    ] : []
  )
}