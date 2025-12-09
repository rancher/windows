locals {
  install_ad_tools = {
    name    = "install_ad_tools.ps1"
    content = file("${path.module}/files/install_ad_tools.ps1")
  }

  install_active_directory = {
    name = "install_active_directory.ps1"
    content = templatefile("${path.module}/files/install_active_directory.ps1", {
      domain_name  = local.active_directory_fqdn
      netbios_name = local.active_directory_netbios_name
      password     = local.active_directory_password
  }) }

  setup_active_directory = {
    name = "setup_active_directory.ps1"
    content = templatefile("${path.module}/files/setup_active_directory.ps1", {
      password                   = local.default_password
      rancher_account            = local.rancher_account
      gmsa_impersonation_account = local.gmsa_impersonation_account
      standard_users             = local.standard_users
      gmsas                      = local.gmsas
    })
  }

  setup_networking = {
    name = "setup_networking.ps1"
    content = templatefile("${path.module}/files/setup_networking.ps1", {
      name        = var.name
      domain_name = local.active_directory_fqdn
  }) }

  setup_integration = {
    name = "setup_integration.ps1"
    content = templatefile("${path.module}/files/setup_integration.ps1", {
      impersonation_account_username = local.gmsa_impersonation_account
      impersonation_account_password = local.default_password
      gmsas                          = local.gmsas
  }) }

}
