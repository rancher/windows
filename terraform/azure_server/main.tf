module "images" {
  source = "../internal/azure/images"
}

module "server" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type       = "simple"
    airgap     = false
    open_ports = var.open_ports
  }

  servers = [
    for i in range(var.replicas) :
    {
      name    = "${var.name}-${i}"
      image   = module.images.source_images[var.image]
      scripts = var.scripts
    }
  ]

  ssh_public_key_path = var.ssh_public_key_path
}

output "server" {
  value = module.server
}
