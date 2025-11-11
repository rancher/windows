module "server" {
  source = "../internal/vsphere/servers"

  servers = [
    for i in range(length(var.servers)) :
    {
      name = "${var.name}-${var.servers[i].image.os}-pool-${i}"
      image = {
        content_library = var.servers[i].image.content_library
        template_path   = var.servers[i].image.template_path
        os              = var.servers[i].image.os
      }
      replicas              = var.servers[i].replicas
      domain_join           = var.active_directory != null && var.servers[i].active_directory_credentials != null
      cpu_count             = var.servers[i].cpu_count
      memory_in_mb          = var.servers[i].memory_in_mb
      disk_size             = var.servers[i].disk_size
      guest_id              = var.servers[i].guest_id
      folder                = var.servers[i].folder
      connection_details    = var.servers[i].connection_details
      scripts               = var.servers[i].scripts
      windows_script_bundle = var.servers[i].windows_script_bundle

      active_directory_credentials = var.servers[i].active_directory_credentials
      sql_server_configuration     = var.servers[i].sql_server_configuration
    }
  ]

  common_connection_details = var.common_connection_details

  # AD specific options, shared for all vms
  active_directory = var.active_directory

  # vCenter specific options, shared for all vms
  data_center     = var.data_center
  resource_pool   = var.resource_pool
  compute_cluster = var.compute_cluster
  datastore       = var.datastore
  network         = var.network
}
