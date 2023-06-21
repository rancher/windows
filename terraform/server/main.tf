module "infrastructure" {
  source = "../internal/server"

  name = "${var.name}"

  server = var.server

  infrastructure      = var.infrastructure
  ssh_public_key_path = var.ssh_public_key_path
}

# Output information to access

output "server" {
  value = module.infrastructure.infrastructure
}
