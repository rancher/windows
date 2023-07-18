locals {
  plan = merge([
    for node in var.nodes : {
      for i in range(node.replicas) : "${var.name}-${node.name}-${i}" => {
        template = node.name
        name     = "${var.name}-${node.name}-${i}"
        subnet   = join("-", sort(node.roles))
        scripts = node.os == "linux" ? [
          templatefile("${path.module}/files/linux/install_docker.sh", {
            docker_version = var.docker_version
          }),
          format("%s %s", var.registration_commands.linux, join(" ", [for role in node.roles : "--${role}"])),
          templatefile("${path.module}/files/linux/rke1_profile.sh", {}),
          contains(node.roles, "controlplane") || contains(node.roles, "etcd") ? templatefile("${path.module}/files/linux/install_calicoctl.sh", {
            calicoctl_version = var.calicoctl_version
          }) : "echo \"No need to install calicoctl.\"",
          contains(node.roles, "etcd") ? templatefile("${path.module}/files/linux/install_etcdctl.sh", {
            etcdctl_version = var.etcdctl_version
          }) : "echo \"No need to install etcdctl.\""
          ] : [
          templatefile("${path.module}/files/windows/install_containers.ps1", {}),
          templatefile("${path.module}/files/windows/install_docker.ps1", {}),
          replace(var.registration_commands.windows, "|", "-worker |")
        ]
      }
    }
  ]...)
}

output "plan" {
  value = local.plan
}