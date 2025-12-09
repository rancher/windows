locals {
  packageManager = [
    {
      content = file("${path.module}/files/install_scoop.ps1")
      name    = "install_scoop.ps1"
    },
  ]

  commonDevScripts = concat(local.packageManager, [
    {
      content = file("${path.module}/files/enable_standard_features.ps1")
      name    = "enable_standard_features.ps1"
    },
    {
      content = file("${path.module}/files/install_docker.ps1")
      name    = "install_docker.ps1"
    },
    {
      content = file("${path.module}/files/install_scoop_tools.ps1")
      name    = "install_scoop_tools.ps1"
    },
    {
      content = file("${path.module}/files/setup_profile.ps1")
      name    = "setup_profile.ps1"
    },
  ])

  advancedDevScripts = concat(local.commonDevScripts, [
    {
      content = file("${path.module}/files/enable_advanced_features.ps1")
      name    = "enable_advanced_features.ps1"
    },
    {
      content = file("${path.module}/files/install_wsl.ps1")
      name    = "install_wsl.ps1"
    },
    {
      content = file("${path.module}/files/install_containerd.ps1")
      name    = "install_containerd.ps1"
    }
  ])

  debugScripts = concat(local.packageManager, [
    {
      content = file("${path.module}/files/enable_standard_features.ps1")
      name    = "enable_standard_features.ps1"
    },
    {
      content = file("${path.module}/files/install_debug_tools.ps1")
      name    = "install_debug_tools.ps1"
    },
    {
      content = file("${path.module}/files/setup_profile.ps1")
      name    = "setup_profile.ps1"
    }
  ])
}
