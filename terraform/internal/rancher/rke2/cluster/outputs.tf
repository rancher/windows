locals {
  linux_registration_command   = trim(data.kubernetes_resource.cluster_registration_token.object.status.insecureNodeCommand, " ")
  windows_registration_command = trim(data.kubernetes_resource.cluster_registration_token.object.status.insecureWindowsNodeCommand, " ")

  registration_commands = {
    linux   = local.linux_registration_command
    windows = join(" ", split(" -Worker ", local.windows_registration_command))
  }
}

output "registration_commands" {
  value = local.registration_commands
}

output "server_url" {
  value = local.server_url
}
