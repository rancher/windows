locals {
  plan = merge([
    for node in var.nodes : {
      for i in range(node.replicas) : "${var.name}-${node.name}-${i}" => {
        template = node.name
        name     = "${var.name}-${node.name}-${i}"
        subnet   = join("-", sort(node.roles))
        scripts = node.os == "linux" ? [
          format("%s %s", var.registration_commands.linux, join(" ", [for role in node.roles : "--${role}"])),
          templatefile("${path.module}/files/linux/rke2_profile.sh", {}),
          contains(node.roles, "controlplane") || contains(node.roles, "etcd") ? templatefile("${path.module}/files/linux/install_calicoctl.sh", {
            calicoctl_version = var.calicoctl_version
          }) : "echo \"No need to install calicoctl.\"",
          contains(node.roles, "etcd") ? templatefile("${path.module}/files/linux/install_etcdctl.sh", {
            etcdctl_version = var.etcdctl_version
          }) : "echo \"No need to install etcdctl.\""
          ] : [
          templatefile("${path.module}/files/windows/install_containers.ps1", {}),
          var.registration_commands.windows,
          templatefile("${path.module}/files/windows/rke2_profile.ps1", {})
        ]
      }
    }
  ]...)
}

output "plan" {
  value = local.plan
}