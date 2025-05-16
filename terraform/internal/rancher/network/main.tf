locals {
  split_subnets = cidrsubnets(var.address_space, 4, 4, 4, 4, 4, 4, 4, 4)

  subnets = var.type == "simple" ? {
    external = {
      address_space = var.address_space
      roles         = tolist(null)
    }
    } : {
    external = {
      address_space = tostring(local.split_subnets[0])
      roles         = tolist(null)
    }
    controlplane = {
      address_space = tostring(local.split_subnets[1])
      roles         = ["controlplane"]
    }
    etcd = {
      address_space = tostring(local.split_subnets[2])
      roles         = ["etcd"]
    }
    worker = {
      address_space = tostring(local.split_subnets[3])
      roles         = ["worker"]
    }
    controlplane-etcd = {
      address_space = tostring(local.split_subnets[4])
      roles         = ["controlplane", "etcd"]
    }
    controlplane-worker = {
      address_space = tostring(local.split_subnets[5])
      roles         = ["controlplane", "worker"]
    }
    etcd-worker = {
      address_space = tostring(local.split_subnets[6])
      roles         = ["etcd", "worker"]
    }
    controlplane-etcd-worker = {
      address_space = tostring(local.split_subnets[7])
      roles         = ["controlplane", "etcd", "worker"]
    }
  }
}

locals {
  address_spaces = {
    "*" = [
      "*"
    ]
    vpc = [
      var.address_space
    ]
    controlplane-etcd = [
      for k, v in local.subnets :
      v.address_space if contains(v.roles == null ? [] : v.roles, "controlplane") || contains(v.roles == null ? [] : v.roles, "etcd")
    ]
    controlplane = [
      for k, v in local.subnets :
      v.address_space if contains(v.roles == null ? [] : v.roles, "controlplane")
    ]
    etcd = [
      for k, v in local.subnets :
      v.address_space if contains(v.roles == null ? [] : v.roles, "etcd")
    ]
    worker = [
      for k, v in local.subnets :
      v.address_space if contains(v.roles == null ? [] : v.roles, "worker")
    ]
    cluster = [
      for k, v in local.subnets :
      v.address_space if v.roles != null
    ]
    external = [
      for k, v in local.subnets :
      v.address_space if v.roles == null
    ]
  }
}

locals {
  basic_rules  = yamldecode(file("${path.module}/files/basic.yaml"))["rules"]
  airgap_rules = yamldecode(file("${path.module}/files/airgap.yaml"))["rules"]
  remote_rules = yamldecode(file("${path.module}/files/remote.yaml"))["rules"]

  # Cluster
  k8s_rules  = yamldecode(file("${path.module}/files/k8s.yaml"))["rules"]
  rke2_rules = yamldecode(file("${path.module}/files/rke2.yaml"))["rules"]

  # CNI
  calico_rules  = yamldecode(file("${path.module}/files/calico.yaml"))["rules"]
  flannel_rules = yamldecode(file("${path.module}/files/flannel.yaml"))["rules"]

  # Open Ports
  open_port_rules = [
    for port in var.open_ports : {
      name        = "open-${port}"
      description = "Allows TCP traffic to port ${port} on hosts in the external subnet"
      direction   = "inbound"
      action      = "allow"
      port_range  = port
      from        = "*"
      to          = "external"
      protocol    = "*"
    }
  ]

  vpc_only_port_rules = flatten([
    for port in var.vpc_only_ports : [
      // NOTE: Deny rules must be applied first in order for the
      //       priority values to be ordered correctly.
      //       This can be removed when we rectify the simple.yaml
      //       rules in the future
      {
        name        = "vpc-only-${port}"
        description = "Denies all traffic from machines outside the VPC to ${port}"
        direction   = "inbound"
        action      = "deny"
        port_range  = port
        from        = "*"
        to          = "*"
        protocol    = "*"
      },
      {
        name        = "vpc-only-${port}"
        description = "Allow all traffic from machines inside the VPC to ${port}"
        direction   = "inbound"
        action      = "allow"
        port_range  = port
        from        = "vpc"
        to          = "*"
        protocol    = "*"
      },
    ]
  ])

  # Rule Templates
  simple_rule_template = concat(
    var.airgap ? local.airgap_rules : local.basic_rules,
    local.remote_rules,
    local.vpc_only_port_rules,
    local.open_port_rules
  )

  rule_templates_without_addresses = {
    simple = local.simple_rule_template
    rke2-calico = concat(
      local.simple_rule_template,
      local.k8s_rules,
      local.rke2_rules,
      local.calico_rules,
    )
    rke1-flannel = concat(
      local.simple_rule_template,
      local.k8s_rules,
      local.flannel_rules,
    )
  }

  rule_templates = {
    for k, v in local.rule_templates_without_addresses : k => [
      for rule in v : merge(rule, {
        from = local.address_spaces[rule.from]
        to   = local.address_spaces[rule.to]
      })
    ]
  }
}

output "vpc" {
  value = {
    address_space = var.address_space
  }
}

output "subnets" {
  value = {
    for k, v in local.subnets : k => v.address_space
  }
}

output "rules" {
  value = local.rule_templates[var.type]
}
