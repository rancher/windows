module "images" {
  source = "../internal/azure/images"
}

module "server" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type = "simple"
    // We hard-code a unique address_space to avoid conflicts with other modules
    // creating a peering relationship with the network created by this module
    address_space  = var.address_space
    airgap         = false
    vpc_only_ports = []
    open_ports = [
      // DirectAccess
      "441",
      "6200",
      "80",
      "443",
      // DNS
      "53",
      // Kerberos
      "88",
      // NetLogon
      "138",
      "139",
      // LDAP ping
      "389",
      // LDAP over SSL
      "636",
      // RPC Endpoint Mapper
      "135",
      // LanmanServer
      "445",
      // RPC Endpoint Mapper for DSCrackNames, SAMR and Netlogon calls between Client and Domain Controller
      "1024-65535"
    ]
  }

  servers = [
    {
      name  = var.name
      image = module.images.source_images["windows"]
      scripts = [
        local.install_active_directory,
        local.setup_active_directory,
        local.setup_networking,
        local.setup_integration
      ]
    }
  ]

  ssh_public_key_path = var.ssh_public_key_path
}
