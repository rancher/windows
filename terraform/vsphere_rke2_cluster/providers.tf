terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10
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

provider "helm" {
  kubernetes {
    config_path = data.external.kubeconfig.result.kubeconfig
  }
}
