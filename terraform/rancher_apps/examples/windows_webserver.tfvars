apps = {
  windows-webserver = {
    path      = "charts/windows-webserver"
    namespace = "cattle-wins-system"
    values = {
      # If you want to test this on a cluster with the Rancher GMSA CCG Plugin
      # gmsa = "gmsa1-ccg"
      # If you want to test this on a domain joined host
      # gmsa = "gmsa1"
    }
  }
}
