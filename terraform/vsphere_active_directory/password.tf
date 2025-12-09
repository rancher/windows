resource "random_string" "active_directory_password" {
  length  = 20
  special = false
}

locals {
  active_directory_password = random_string.active_directory_password.result
}
