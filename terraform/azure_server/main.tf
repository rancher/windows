module "images" {
  source = "../internal/azure/images"
}

locals {
  scripts = var.dev_tools && module.images.source_images[var.image].os == "windows" ? concat(
    [
      file("${path.module}/files/enable_features.ps1"),
      file("${path.module}/files/install_choco.ps1"),
      file("${path.module}/files/setup_profile.ps1"),
      file("${path.module}/files/install_docker.ps1"),
      file("${path.module}/files/install_containerd.ps1"),
      file("${path.module}/files/install_wsl.ps1")
    ],
    var.scripts
  ) : var.scripts
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
      scripts     = local.scripts
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
