# create OU for testing
resource "ad_ou" "o" {
  name        = "TestOU"
  path        = var.path
  description = "OU for standard tests"
  protected   = false
}

resource "ad_ou" "o2" {
  name        = "gplinktestOU"
  path        = var.path
  description = "OU for gplink tests"
  protected   = false
}

# create users
resource ad_user "user1" {
    display_name     = "Terraform Test User1"
    principal_name   = "testUser1"
    sam_account_name = "testUser1"
    initial_password = "Rancher123!!@@"
}

resource ad_user "user2" {
    display_name     = "Terraform Test User2"
    principal_name   = "testUser2"
    sam_account_name = "testUser2"
    initial_password = "Rancher123!!@@"
    container        = ad_ou.o.dn
}

resource ad_user "user3" {
    display_name     = "Terraform Test User3"
    principal_name   = "testUser3"
    sam_account_name = "testUser3"
    initial_password = "Rancher123!!@@"
    container        = ad_ou.o2.dn
}

# create groups
resource "ad_group" "global" {
  name             = var.ad_group_name
  sam_account_name = var.ad_sam_name
  scope            = "global"
  category         = "security"
  container        = ad_ou.o.dn
}

resource ad_group "domainlocal" {
    name             = "${var.ad_group_name} 2"
    sam_account_name = "${var.ad_sam_name}-2"
    container        = ad_ou.o.dn
    category         = "security"
    scope            = "domainlocal"
}

resource ad_group "universal" {
    name             = "${var.ad_group_name} 3"
    sam_account_name = "${var.ad_sam_name}-3"
    container        = ad_ou.o.dn
    scope            = "universal"
    category         = "security"
}

# create group memberships
resource ad_group_membership "gm1" {
    group_id = ad_group.global.id
    group_members  = [ ad_group.global.id, ad_user.user1.id, ad_user.user2.id ]
}

resource ad_group_membership "gm2" {
    group_id = ad_group.domainlocal.id
    group_members  = [ ad_group.domainlocal.id, ad_user.user1.id, ad_user.user2.id ]
}

resource ad_group_membership "gm3" {
    group_id = ad_group.universal.id
    group_members  = [ ad_group.universal.id, ad_user.user1.id, ad_user.user2.id ]
}

# create gpo object
resource "ad_gpo" "gpo1" {
  name        = "gplinktestGPO"
  domain      = var.domain
  description = "gpo1 for gplink tests"
  status      = "AllSettingsEnabled"
}

resource "ad_gpo" "gpo2" {
  name        = "gplinktestGPO"
  domain      = var.domain
  description = "gpo2 for gplink tests"
  status      = "AllSettingsEnabled"
}


# create gplink
resource "ad_gplink" "link1" {
  gpo_guid  = ad_gpo.gpo1.id
  target_dn = ad_ou.o.dn
  enforced  = true
  enabled   = true
}

# create gplink
resource "ad_gplink" "link2" {
  gpo_guid  = ad_gpo.gpo2.id
  target_dn = ad_ou.o2.dn
  enforced  = true
  enabled   = true
}