locals {
  windows_enable_containers_script = <<-EOT
    Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart;
    EOT

  windows_enable_ssh_script = <<-EOT
    Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';
    EOT
}