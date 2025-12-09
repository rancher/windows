locals {
  # Account for Rancher Integration
  rancher_account = "Rancher"

  # Account for gMSA Integration
  gmsa_impersonation_account = "GMSAImpersonator"

  # NetBIOS name for the Active Directory instance
  active_directory_netbios_name = "ad"
}

locals {
  active_directory_domain = "ad.com"
  active_directory_fqdn   = "${var.name}.${local.active_directory_domain}"
}

locals {
  default_password = var.default_password

  standard_users = var.standard_users
  gmsas          = var.gmsas
}
