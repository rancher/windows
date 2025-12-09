module "server" {
  source = "../internal/vsphere/servers"

  servers = [
    {
      name = var.name

      cpu_count    = 16
      memory_in_mb = 16384
      disk_size    = 80
      guest_id     = "windows2019srvNext_64Guest"
      replicas     = 1

      folder = var.folder

      scripts = [
        local.install_ad_tools,
        local.install_active_directory,
        local.setup_active_directory,
        local.setup_networking,
        local.setup_integration
      ]
      image = {
        content_library = var.content_library
        os              = "windows"
      }
      connection_details    = var.connection_details
      windows_script_bundle = var.windows_script_bundle
    }
  ]

  data_center     = var.data_center
  datastore       = var.datastore
  compute_cluster = var.compute_cluster
  network         = var.network
  resource_pool   = var.resource_pool
}
