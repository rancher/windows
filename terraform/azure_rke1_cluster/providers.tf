terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.56.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "external" "kubeconfig" {
  program = ["bash", "-c", "echo \"{\\\"kubeconfig\\\": \\\"$KUBECONFIG\\\"}\""]

  lifecycle {
    postcondition {
      condition     = length(self.result.kubeconfig) > 0
      error_message = "Please point your KUBECONFIG to a cluster by running 'export KUBECONFIG=<access-key>' before running a terraform apply."
    }
  }
}

provider "kubernetes" {
  config_path = data.external.kubeconfig.result.kubeconfig
}
