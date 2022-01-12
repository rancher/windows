variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "us-east-1"
}

variable "owner" {
  type        = string
  description = "Owner tag value for AWS instances"
}

variable "aws_credentials_file" {
  type        = string
  description = "Full path to the local AWS credentials file"
}

variable "aws_profile" {
  description = "Name of the profile to use from the AWS credentials file"
  type    = string
}