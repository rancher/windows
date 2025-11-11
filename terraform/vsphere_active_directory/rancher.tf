#
# locals {
#   ad_rancher_integration_path = "${var.name}-rancher-integration.yaml"
#
#   base_distinguished_name  = "DC=${join(",DC=", split(".", local.active_directory_fqdn))}"
#   admin_distinguished_name = "CN=${local.rancher_account},CN=Users,${local.base_distinguished_name}"
#
#   authconfig_yaml = templatefile("${path.module}/files/authconfig.yaml", {
#     distinguished_name  = local.admin_distinguished_name
#     active_directory_ip = module.server.machines[var.name].public_ip
#     account             = local.rancher_account
#     user_search_base    = local.base_distinguished_name
#     password            = local.default_password
#     netbios_name        = local.active_directory_netbios_name
#   })
# }
#
# resource "local_file" "active_directory_rancher_integration" {
#   content  = local.authconfig_yaml
#   filename = "${path.cwd}/${local.ad_rancher_integration_path}"
# }
