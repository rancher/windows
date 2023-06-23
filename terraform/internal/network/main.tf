locals {
  vpc = var.vpc

  subnets = var.type == "simple" ? {
    external = var.subnets.external
  } : var.subnets
}

locals {
    address_spaces = {
    "*" = [
        "*"
    ]
    vpc = [
        var.vpc.address_space
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
  basic_rules = yamldecode(file("files/basic.yaml"))["rules"]
  airgap_rules = yamldecode(file("files/airgap.yaml"))["rules"]
  remote_rules = yamldecode(file("files/remote.yaml"))["rules"]
  
  # Cluster
  k8s_rules = yamldecode(file("files/k8s.yaml"))["rules"]
  rke2_rules = yamldecode(file("files/rke2.yaml"))["rules"]

  # CNI
  calico_rules = yamldecode(file("files/calico.yaml"))["rules"]
  flannel_rules = yamldecode(file("files/flannel.yaml"))["rules"]

  # Open Ports
  open_port_rules = [
    for port in var.open_ports : {
        name = "tcp-${port}"
        description = "Allows TCP traffic to port ${port} on hosts in the external subnet"
        direction = "inbound"
        access = "allow"
        port_range = "${port}"
        from = "*"
        to = "external"
        protocol = "tcp"
    }
  ]

  # Rule Templates
  simple_rule_template = concat(
    var.airgap ? local.basic_rules : local.airgap_rules,
    local.remote_rules,
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
            to = local.address_spaces[rule.to]
        })
    ]
  }
}

output "vpc" {
    value = local.vpc
}

output "subnets" {
    value = {
        for k, v in local.subnets : k => v.address_space
    }
}

output "rules" {
    value = local.rule_templates[var.type]
}

