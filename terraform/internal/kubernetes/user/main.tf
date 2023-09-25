resource "random_pet" "user" {
}

locals {
  name = random_pet.user.id
}

resource "tls_private_key" "user" {
  algorithm = "RSA"
}

resource "tls_cert_request" "user" {
  private_key_pem = tls_private_key.user.private_key_pem

  subject {
    common_name  = local.name
    organization = "rancher-dev"
  }
}

locals {
  init_user_script = templatefile("${path.module}/files/init_user.sh", {
    user               = local.name
    api_server_address = var.api_server_address
    private_key_pem    = tls_private_key.user.private_key_pem
    cert_request_pem   = tls_cert_request.user.cert_request_pem
  })
}

resource "local_file" "init_user_script" {
  count = var.create_file ? 1 : 0

  content  = local.init_user_script
  filename = "${path.cwd}/${local.name}-init-user.sh"
}

output "script" {
  value = var.create_file ? null : nonsensitive(local.init_user_script)
}

output "name" {
  value = local.name
}

output "commands" {
  value = var.create_file ? {
    run     = "./${local.name}-cluster-init.sh"
    kubectl = "kubectl --kubeconfig ${local.name}.kubeconfig get nodes"
  } : null
}
