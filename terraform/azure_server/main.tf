module "images" {
  source = "../internal/azure/images"
}

module "server" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type          = "simple"
    address_space = var.address_space
    airgap        = false
    open_ports    = var.open_ports
  }

  servers = [
    for i in range(var.replicas) :
    {
      name        = "${var.name}-${i}"
      image       = module.images.source_images[var.image]
      scripts     = var.scripts
      domain_join = var.active_directory != null && var.domain_join
    }
  ]

  active_directory = var.active_directory

  ssh_public_key_path = var.ssh_public_key_path
}

output "server" {
  value = {
    machines = module.server.machines
    debug    = module.server.debug
  }
}
