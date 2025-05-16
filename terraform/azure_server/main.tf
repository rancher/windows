module "images" {
  source = "../internal/azure/images"
}

locals {

  packageManager = [
    file("${path.module}/files/install_scoop.ps1"),
  ]

  commonDevScripts = concat(local.packageManager, [
    file("${path.module}/files/enable_standard_features.ps1"),
    file("${path.module}/files/install_docker.ps1"),
    file("${path.module}/files/install_scoop_tools.ps1"),
    file("${path.module}/files/setup_profile.ps1"),
  ])

  advancedDevScripts = concat(local.commonDevScripts, [
    file("${path.module}/files/enable_advanced_features.ps1"),
    file("${path.module}/files/install_wsl.ps1"),
    file("${path.module}/files/install_containerd.ps1"),
  ])

  debugScripts = concat(local.packageManager, [
    file("${path.module}/files/enable_standard_features.ps1"),
    file("${path.module}/files/install_debug_tools.ps1"),
    file("${path.module}/files/setup_profile.ps1"),
  ])

  scriptMap = {
    "devtools" = {
      enabled = var.dev_tools
      scripts = local.commonDevScripts
    },
    "advancedDev" = {
      enabled = var.advanced_dev_tools
      scripts = local.advancedDevScripts
    },
    "debug" = {
      enabled = var.debug_tools
      scripts = local.debugScripts
    }
  }

  scripts = [for scriptType in local.scriptMap : scriptType.scripts if scriptType.enabled]
}

module "server" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type          = "simple"
    address_space = var.address_space
    airgap        = false
    open_ports    = var.open_ports
    vpc_ports     = var.vpc_only_ports
  }

  servers = [
    for i in range(var.replicas) :
    {
      name        = "${var.name}-${i}"
      image       = module.images.source_images[var.image]
      scripts     = length(local.scripts) > 0 ? local.scripts[0] : []
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
