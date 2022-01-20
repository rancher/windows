terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    ad = {
      source = "hashicorp/ad"
      version = "~> 0.4.3"
    }
  }
}