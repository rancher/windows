locals {
  install_active_directory = templatefile("${path.module}/files/install_active_directory.ps1", {
    domain_name  = local.active_directory_fqdn
    netbios_name = local.active_directory_netbios_name
    password     = local.active_directory_password
  })

  setup_active_directory = templatefile("${path.module}/files/setup_active_directory.ps1", {
    password                   = local.default_password
    rancher_account            = local.rancher_account
    gmsa_impersonation_account = local.gmsa_impersonation_account
    standard_users             = local.standard_users
    gmsas                      = local.gmsas
    # hosts                      = local.hosts
  })

  setup_networking = templatefile("${path.module}/files/setup_networking.ps1", {
    name        = var.name
    domain_name = local.active_directory_fqdn
    # The assumption here is that the Active Directory instance should exist in a
    # network that each VM has access to (i.e. the network each VM exists within
    # should be peered with the AD network) and the VM should have an IP of the 
    # format 10.X.Y.Z, where X, Y, and Z can be any number from 0-255.
    # This is where the network prefix length of 8 bits * 3 spaces comes from.
    network_prefix_length = 8 * 3
  })

  setup_integration = templatefile("${path.module}/files/setup_integration.ps1", {
    impersonation_account_username = local.gmsa_impersonation_account
    impersonation_account_password = local.default_password
    gmsas                          = local.gmsas
  })
}
