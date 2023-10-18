nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["controlplane", "etcd", "worker"]
    replicas = 1
  },
  {
    name        = "windows-server"
    image       = "windows"
    roles       = ["worker"]
    replicas    = 1
    domain_join = true
  }
]

apps = {
  cert-manager-crd = {
    path      = "https://github.com/cert-manager/cert-manager/releases/download/v1.12.4/cert-manager.crds.yaml"
    namespace = "cert-manager"
  }

  cert-manager = {
    path         = "https://charts.jetstack.io//charts/cert-manager-v1.12.4.tgz"
    namespace    = "cert-manager"
    values       = {}
    dependencies = ["cert-manager-crd"]
  }

  # This is a hack that has been put into place to support an existing bug in the
  # current rancher-gmsa-webhook chart. Currently, if the admission webhook is deployed
  # before the webhook Pod itself is deployed, the webhook will not be able to start because
  # the Kubernetes API server will attempt to reach out to the webhook to verify the webhook Pod,
  # which is a circular dependency. To resolve this, we add the namespace we deploy the webhook
  # pod onto as one where the admission webhook is disabled.
  hack-gmsa-namespace = {
    manifest = <<-EOT
    apiVersion: v1
    kind: Namespace
    metadata:
        name: cattle-windows-gmsa-system
        labels:
          gmsa-webhook: disabled
    EOT
  }

  gmsa-crd = {
    path         = "https://charts.rancher.io/assets/rancher-windows-gmsa-crd/rancher-windows-gmsa-crd-2.0.0.tgz"
    namespace    = "cattle-windows-gmsa-system"
    values       = {}
    dependencies = ["hack-gmsa-namespace"]
  }

  gmsa = {
    path      = "https://charts.rancher.io/assets/rancher-windows-gmsa/rancher-windows-gmsa-2.0.0.tgz"
    namespace = "cattle-windows-gmsa-system"
    values = {
      credential = {
        enabled = false
      }
    }
    dependencies = ["gmsa-crd", "cert-manager"]
  }

  windows-ad-setup = {
    path      = "charts/windows-ad-setup"
    namespace = "cattle-windows-gmsa-system"
    # Comment this out if you are not using the Active Directory Terraform module
    #
    # This will cause a failure unless you have run the script in the setup_integration
    # output of the Active Directory Terraform module
    #
    # Alternatively, you can manually create the expected `values.json` for an external Active Directory
    values_file  = "dist/active_directory/values.json"
    dependencies = ["gmsa"]
  }

  windows-gmsa-webserver = {
    path      = "charts/windows-gmsa-webserver"
    namespace = "cattle-wins-system"
    values = {
      gmsa = "gmsa1"
    }
    dependencies = ["windows-ad-setup"]
  }
}
