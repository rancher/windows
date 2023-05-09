# create OU for testing

# OU 'o' will have three active directory groups
# attached to it, 'domainlocal', 'global', and 'universal'.
# it will also have a group policy object and group policy object link
# added to it.
resource "ad_ou" "o" {
  name        = "TestOU"
  path        = var.path
  description = "OU for standard tests"
  protected   = false
}

# OU 'o2' will have a group policy object and group policy object link
# added to it.
resource "ad_ou" "o2" {
  name        = "gplinktestOU"
  path        = var.path
  description = "OU for gplink tests"
  protected   = false
}

resource "ad_user" "all_users" {
  for_each = {for user in var.active_directory_users: user.display_name => user}

  display_name     = each.value.display_name
  principal_name   = each.value.principal_name
  sam_account_name = each.value.sam_account_name
  initial_password = each.value.initial_password

  container = each.value.organizational_unit == "TestOU" ? ad_ou.o.dn : ad_ou.o2.dn
}

# create 3 static groups within the TestOU, each with
# a different scope so that all scopes can be tested.
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

# create assign users to particular group memberships
# based off of the users 'group' attribute
resource ad_group_membership "gm1" {
    group_id = ad_group.global.id
    group_members  = concat(local.gm1_users[0], [ad_group.global.id])
}

resource ad_group_membership "gm2" {
    group_id = ad_group.domainlocal.id
    group_members = concat(local.gm2_users[0], [ad_group.domainlocal.id])
}

resource ad_group_membership "gm3" {
    group_id = ad_group.universal.id
    group_members  = concat(local.gm3_users[0], [ad_group.universal.id])
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

locals {
  gm1_users = tolist([for each in var.active_directory_users : [
     for eachuser in ad_user.all_users: eachuser.id if each.group == "global"
    ]])

  gm2_users = tolist([for each in var.active_directory_users : [
     for eachuser in ad_user.all_users: eachuser.id if each.group == "universal"
  ]])

  gm3_users = tolist([for each in var.active_directory_users : [
    for eachuser in ad_user.all_users: eachuser.id if each.group == "domainlocal"
  ]])
}