terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.90.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "external" "do_access_key" {
  count = var.create_record ? 1 : 0

  program = ["bash", "-c", "echo \"{\\\"do_access_key\\\": \\\"$DO_ACCESS_KEY\\\"}\""]

  lifecycle {
    postcondition {
      condition     = length(self.result.do_access_key) > 0
      error_message = "Please set the DigitalOcean Token by running 'export DO_ACCESS_KEY=<access-key>' before running a terraform apply."
    }
  }
}

locals {
  do_access_key = var.create_record ? data.external.do_access_key[0].result.do_access_key : ""
}

provider "digitalocean" {
  // Digital Ocean Token comes from DO_ACCESS_KEY environment variable
  token = local.do_access_key
}
