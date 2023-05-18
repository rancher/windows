module "images" {
  source = "../images"

  infrastructure_provider = var.infrastructure.azure.enabled ? "azure" : ""
}

locals {
  source_images = module.images.source_images
}

module "azure" {
  count = var.infrastructure.azure.enabled ? 1 : 0

  source = "../azure"

  group               = var.name
  ssh_public_key_path = var.ssh_public_key_path

  location = var.infrastructure.azure.location
  network = {
    simple = {
      enabled    = true
      open_ports = var.server.open_ports
    }
  }

  servers = [merge(var.server, {
    image = {
      publisher = local.source_images[var.server.image].publisher
      offer     = local.source_images[var.server.image].offer
      sku       = local.source_images[var.server.image].sku
      version   = local.source_images[var.server.image].version
      os        = local.source_images[var.server.image].os
    }
    subnet       = "external"
    boot_scripts = []
    scripts      = concat(local.source_images[var.server.image].scripts, var.server.scripts)
  })]
}

output "infrastructure" {
  value = merge(
    module.azure...
  )
}