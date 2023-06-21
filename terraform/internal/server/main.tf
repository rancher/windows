locals {
  ssh_public_key = file(var.ssh_public_key_path)
}

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
    boot_scripts = concat(local.source_images[var.server.image].scripts, var.server.boot_scripts)
    scripts = local.source_images[var.server.image].os != "windows" ? var.server.scripts : concat(
      [
        <<-EOT
          Start-Service sshd;
          Set-Service -Name sshd -StartupType 'Automatic';
          Add-Content -Path 'C:\ProgramData\ssh\administrators_authorized_keys' -Value '${local.ssh_public_key}';
          icacls.exe 'C:\ProgramData\ssh\administrators_authorized_keys' /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F';
        EOT
      ],
      var.server.scripts
    )
  })]
}

output "infrastructure" {
  value = merge(
    module.azure...
  )
}