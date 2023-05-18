locals {
  vpc = {
    address_space = "10.0.0.0/16"
  }

  subnets = merge({
    external = {
      address_prefix = "10.0.224.0/19"
      roles          = null
    }
    }, !var.network.simple.enabled ? {
    controlplane = {
      address_prefix = "10.0.32.0/19"
      roles          = ["controlplane"]
    }
    etcd = {
      address_prefix = "10.0.0.0/19"
      roles          = ["etcd"]
    }
    worker = {
      address_prefix = "10.0.64.0/19"
      roles          = ["worker"]
    }
    controlplane-etcd = {
      address_prefix = "10.0.96.0/19"
      roles          = ["controlplane", "etcd"]
    }
    controlplane-worker = {
      address_prefix = "10.0.160.0/19"
      roles          = ["controlplane", "worker"]
    }
    etcd-worker = {
      address_prefix = "10.0.128.0/19"
      roles          = ["etcd", "worker"]
    }
    controlplane-etcd-worker = {
      address_prefix = "10.0.192.0/19"
      roles          = ["controlplane", "etcd", "worker"]
    }
  } : {})

  address_prefixes = {
    controlplane = [
      for k, v in local.subnets :
      v.address_prefix if contains(v.roles == null ? [] : v.roles, "controlplane")
    ]
    etcd = [
      for k, v in local.subnets :
      v.address_prefix if contains(v.roles == null ? [] : v.roles, "etcd")
    ]
    worker = [
      for k, v in local.subnets :
      v.address_prefix if contains(v.roles == null ? [] : v.roles, "worker")
    ]
    cluster = [
      for k, v in local.subnets :
      v.address_prefix if v.roles != null
    ]
    none = [
      for k, v in local.subnets :
      v.address_prefix if v.roles == null
    ]
  }

  simple_rules = [
    {
      name                         = "deny-inbound"
      description                  = "Deny all inbound traffic by default"
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_range       = "*"
      destination_port_ranges      = null
      source_address_prefix        = "*"
      destination_address_prefix   = "*"
      source_address_prefixes      = null
      destination_address_prefixes = null
    },
    {
      name                         = "allow-outbound"
      description                  = "Allow all outbound traffic by default"
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_range       = "*"
      destination_port_ranges      = null
      source_address_prefix        = "*"
      destination_address_prefix   = "*"
      source_address_prefixes      = null
      destination_address_prefixes = null
    },
    {
      name                         = "allow-ssh"
      description                  = "Allow ssh into nodes by default"
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_range       = "22"
      destination_port_ranges      = null
      source_address_prefix        = "*"
      destination_address_prefix   = "*"
      source_address_prefixes      = null
      destination_address_prefixes = null
    },
    {
      name                         = "allow-rdp"
      description                  = "Allow RDP connections to nodes by default"
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_range       = "3389"
      destination_port_ranges      = null
      source_address_prefix        = "*"
      destination_address_prefix   = "*"
      source_address_prefixes      = null
      destination_address_prefixes = null
    }
  ]

  cni_rules = {
    calico = [
      {
        name                         = "allow-calico-vxlan"
        description                  = "Allow all nodes to access Calico VXLAN port on all other nodes"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_range       = "4789"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["cluster"]
        destination_address_prefixes = local.address_prefixes["cluster"]
      },
      {
        name                         = "allow-calico-health-checks"
        description                  = "Allow controlplane nodes to execute Calico health checks on all other nodes"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "9099"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["controlplane"]
        destination_address_prefixes = local.address_prefixes["cluster"]
      }
    ]
    flannel = [
      {
        name                         = "allow-flannel-vxlan"
        description                  = "Allow all nodes to access Flannel VXLAN port on hosts"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_range       = "8472"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["cluster"]
        destination_address_prefixes = local.address_prefixes["cluster"]
      },
      {
        name                         = "allow-flannel-vxlan-windows"
        description                  = "Allow all nodes to access Flannel VXLAN port on Windows hosts"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Udp"
        source_port_range            = "*"
        destination_port_range       = "4789"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["cluster"]
        destination_address_prefixes = local.address_prefixes["cluster"]
      },
      {
        name                         = "allow-flannel-health-checks"
        description                  = "Allow controlplane nodes to execute Flannel health checks on all other nodes"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "9099"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["controlplane"]
        destination_address_prefixes = local.address_prefixes["cluster"]
      }
    ]
  }

  distribution_rules = {
    rke2 = [
      {
        name                         = "allow-node-port"
        description                  = "Allow external traffic to NodePorts"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "*"
        source_port_range            = "*"
        destination_port_range       = "30000-32767"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        destination_address_prefix   = null
        source_address_prefixes      = null
        destination_address_prefixes = local.address_prefixes["cluster"]
      },
      {
        name                       = "allow-node-join"
        description                = "Allow all nodes to access the join URL port on etcd nodes"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9345"
        destination_port_ranges    = null
        direction                  = "Inbound"
        source_address_prefix      = null
        destination_address_prefix = null
        source_address_prefixes    = local.address_prefixes["cluster"]
        destination_address_prefixes = concat(
          local.address_prefixes["etcd"],
          // note: controlplane added here so that the kubelets on worker nodes can talk to the apiserver
          local.address_prefixes["controlplane"]
        )
      },
      {
        name                    = "allow-cluster-apiserver"
        description             = "Allow all servers to accesss the apiserver on controlplane nodes"
        access                  = "Allow"
        protocol                = "Tcp"
        source_port_range       = "*"
        destination_port_range  = "6443"
        destination_port_ranges = null
        direction               = "Inbound"
        // note: you do not need the apiserver to be accessible from anywhere on the internet since
        // rancher is supposed to provide access to the apiserver via the remotedialer tunnel
        source_address_prefix        = local.vpc.address_space
        destination_address_prefix   = null
        source_address_prefixes      = null
        destination_address_prefixes = local.address_prefixes["controlplane"]
      },
      {
        name                         = "allow-cluster-kubelet"
        description                  = "Allow controlplane to access kubelet on workers for health checks"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "10250"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["controlplane"]
        destination_address_prefixes = local.address_prefixes["worker"]
      },
      {
        name                       = "allow-cluster-etcd"
        description                = "Allow etcd and controlplane to access etcd ports"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = null
        destination_port_ranges    = ["2379", "2380"]
        direction                  = "Inbound"
        source_address_prefix      = null
        destination_address_prefix = null
        source_address_prefixes = concat(
          local.address_prefixes["etcd"],
          // note: controlplane added here so that it can execute healthchecks on etcd
          local.address_prefixes["controlplane"]
        )
        destination_address_prefixes = local.address_prefixes["etcd"]
      }
    ]
    rke1 = [
      {
        name                         = "allow-node-port"
        description                  = "Allow external traffic to NodePorts"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "*"
        source_port_range            = "*"
        destination_port_range       = "30000-32767"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        destination_address_prefix   = null
        source_address_prefixes      = null
        destination_address_prefixes = local.address_prefixes["cluster"]
      },
      {
        name                    = "allow-cluster-apiserver"
        description             = "Allow all servers to accesss the apiserver on controlplane nodes"
        access                  = "Allow"
        protocol                = "Tcp"
        source_port_range       = "*"
        destination_port_range  = "6443"
        destination_port_ranges = null
        direction               = "Inbound"
        // note: you do not need the apiserver to be accessible from anywhere on the internet since
        // rancher is supposed to provide access to the apiserver via the remotedialer tunnel
        source_address_prefix        = local.vpc.address_space
        destination_address_prefix   = null
        source_address_prefixes      = null
        destination_address_prefixes = local.address_prefixes["controlplane"]
      },
      {
        name                         = "allow-cluster-kubelet"
        description                  = "Allow controlplane to access kubelet on workers for health checks"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "10250"
        destination_port_ranges      = null
        source_address_prefix        = null
        destination_address_prefix   = null
        source_address_prefixes      = local.address_prefixes["controlplane"]
        destination_address_prefixes = local.address_prefixes["worker"]
      },
      {
        name                       = "allow-cluster-etcd"
        description                = "Allow etcd and controlplane to access etcd ports"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = null
        destination_port_ranges    = ["2379", "2380"]
        direction                  = "Inbound"
        source_address_prefix      = null
        destination_address_prefix = null
        source_address_prefixes = concat(
          local.address_prefixes["etcd"],
          // note: controlplane added here so that it can execute healthchecks on etcd
          local.address_prefixes["controlplane"]
        )
        destination_address_prefixes = local.address_prefixes["etcd"]
      }
    ]
  }

  rule_templates = {
    simple = [
      for port in var.network.simple.open_ports :
      {
        name                         = "open-${port}"
        description                  = "Opens ${port} on the host"
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "*"
        source_port_range            = "*"
        destination_port_range       = "${port}"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        destination_address_prefix   = "*"
        source_address_prefixes      = null
        destination_address_prefixes = null
      }
    ]
    rke2-calico  = concat(local.distribution_rules["rke2"], local.cni_rules["calico"])
    rke1-flannel = concat(local.distribution_rules["rke1"], local.cni_rules["flannel"])
  }

  rules_without_priority = concat(local.simple_rules, local.rule_templates[!var.network.simple.enabled ? var.network.template : "simple"])

  rules = [
    for i, v in local.rules_without_priority :
    merge(v, {
      priority = 4096 - i
    })
  ]
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [local.vpc.address_space]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = local.rules

    content {
      name                         = security_rule.value.name
      description                  = security_rule.value.description
      priority                     = security_rule.value.priority
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      direction                    = security_rule.value.direction
      source_address_prefix        = security_rule.value.source_address_prefix
      destination_address_prefix   = security_rule.value.destination_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefixes = security_rule.value.destination_address_prefixes
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = local.subnets

  name                 = "${local.prefix}-${each.key}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name

  address_prefixes = [each.value.address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "subnet_to_nsg" {
  for_each = local.subnets

  subnet_id                 = local.generated_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

locals {
  generated_subnets = zipmap(keys(local.subnets), values(azurerm_subnet.subnets))
}
