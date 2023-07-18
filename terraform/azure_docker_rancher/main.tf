# Create the Rancher instance
resource "random_string" "rancher_password" {
  length  = 20
  special = false
}

locals {
  rancher_password = random_string.rancher_password.result
}

module "images" {
  source = "../internal/azure/images"
}

module "server" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type       = "simple"
    airgap     = false
    open_ports = [80, 443, 6443]
  }

  servers = [
    {
      name  = var.name
      image = module.images.source_images["linux"]
      scripts = [
        templatefile("${path.module}/files/install_docker.sh", {
          docker_version = var.docker_version
        }),
        templatefile("${path.module}/files/install_or_upgrade_rancher.sh", {
          replace            = var.replace ? timestamp() : null
          bootstrap_password = local.rancher_password
          image              = "${var.registry_hostname}/rancher:v${var.rancher_version}"
        })
      ]
    }
  ]

  ssh_public_key_path = var.ssh_public_key_path
}

resource "digitalocean_record" "rancher_dns" {
  count = var.create_record ? 1 : 0

  domain = "cp-dev.rancher.space"
  type   = "A"
  name   = var.name
  value  = local.rancher_ip
}

locals {
  rancher_ip = module.server.machines[var.name].public_ip

  server_url = "https://${var.create_record ? digitalocean_record.rancher_dns[0].fqdn : local.rancher_ip}"

  rancher_logs = join("'sudo docker logs rancher -f'", matchkeys(split("'",
    module.server.machines[var.name].ssh_command
  ), [true, false, true], [true]))
}

# Output information to access

output "rancher" {
  value = merge(module.server, {
    server_url       = local.server_url
    rancher_password = local.rancher_password
    rancher_logs     = local.rancher_logs
  })
}
