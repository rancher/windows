locals {
  windows_enable_containers_script = <<-EOT
    Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart;
    EOT

  windows_enable_ssh_script = <<-EOT
    Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';
    EOT
}

locals {
  linux_images = {
    ubuntu-1804 = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      scripts   = []
    }
    sles-15 = {
      publisher = "SUSE"
      offer     = "sles-15-sp3"
      sku       = "gen2"
      scripts   = []
    }
    rhel-8 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "8-lvm-gen2"
      scripts   = []
    }
    opensuse-leap-15-4 = {
      publisher = "SUSE"
      offer     = "openSUSE-leap-15-4"
      sku       = "gen2"
      scripts   = []
    }
    centos-7 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "7.5"
      scripts   = []
    }
  }

  windows_images = {
    windows-2019-core = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter-Core"
      scripts   = [local.windows_enable_ssh_script, local.windows_enable_containers_script]
    }
    windows-2019 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      scripts   = [local.windows_enable_ssh_script, local.windows_enable_containers_script]
    }
    windows-2022-core = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-core"
      scripts   = [local.windows_enable_ssh_script, local.windows_enable_containers_script]
    }
    windows-2022 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter"
      scripts   = [local.windows_enable_ssh_script, local.windows_enable_containers_script]
    }
  }

  source_images = {
    for k, v in merge(
      { for k, v in merge(local.linux_images, {
        // set default
        linux = local.linux_images["ubuntu-1804"]
      }) : k => merge(v, { os = "linux" }) },
      { for k, v in merge(local.windows_images, {
        // set default
        windows = local.windows_images["windows-2019-core"]
      }) : k => merge(v, { os = "windows" }) },
    ) :
    k => merge(v, { version = "latest" })
  }
}


output "source_images" {
  value = local.source_images
}