variable "domain" { 
  type = string 
  description = "AD domain"
}

variable "path" { 
  type = string 
  description = "AD path"
}

variable "ad_group_name" { 
    type = string 
    description = "Base name for AD Groups"
}

variable "ad_sam_name" { 
    type = string 
    description = "Base name for SAM Accounts"
}

variable "active_directory_users" {
  type = list(object({
    organizational_unit = string
    display_name = string
    principal_name = string
    sam_account_name = string
    initial_password = string
    # e.g. global, domainlocal, universal
    group = string
  }))
}