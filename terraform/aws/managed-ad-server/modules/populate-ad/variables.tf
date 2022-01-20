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