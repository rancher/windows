variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "us-east-1"
}

variable "owner" {
  type        = string
  description = "Owner tag value for AWS instances"
}

variable "prefix" {
  type        = string
  description = "string to append to the name of AWS instances"
}

variable "aws_credentials_file" {
  type        = string
  description = "Full path to the local AWS credentials file"
}

variable "aws_profile" {
  description = "Name of the profile to use from the AWS credentials file"
  type    = string
}

variable "vpc_name" {
  description = "Name of the AWS VPC that you want to create"
  type = string 
}

variable "windows_admin_password" {
  description = "the password for the `rancher` administrator user"
  type = string 
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

variable "ad_name" {
  type = string
  description = "name of the active directory aws instance"
}