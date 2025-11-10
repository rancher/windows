/*
    DESCRIPTION:
    Microsoft Windows Server 2025 variables used by the Packer Plugin for VMware vSphere (vsphere-iso).
*/

// Installation Operating System Metadata
vm_inst_os_language                 = "en-US"
vm_inst_os_keyboard                 = "en-US"
vm_inst_os_image_standard_core      = "Windows Server 2025 SERVERSTANDARDCORE"
vm_inst_os_image_standard_desktop   = "Windows Server 2025 SERVERSTANDARD"
vm_inst_os_image_datacenter_core    = "Windows Server 2025 SERVERDATACENTERCORE"
vm_inst_os_image_datacenter_desktop = "Windows Server 2025 SERVERDATACENTER"
# https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys?tabs=windows1110ltsc%2Cwindows81%2Cserver2025%2Cversion1803
vm_inst_os_kms_key_standard         = "TVRH6-WHNXV-R9WG3-9XRFY-MY832"
vm_inst_os_kms_key_datacenter       = "D764K-2NDRG-47T6Q-P8T8W-YP6DF"

/*
   Selecting OS versions via an index is more reliable than using
   the string value of the OS version. For all Windows ISO's, the
   order will be the same as below.
*/
vm_inst_os_image_standard_core_index = 1
vm_inst_os_image_standard_desktop_index = 2
vm_inst_os_image_datacenter_core_index = 3
vm_inst_os_image_datacenter_desktop_index = 4

// Guest Operating System Metadata
vm_guest_os_language           = "en-US"
vm_guest_os_keyboard           = "en-US"
vm_guest_os_timezone           = "UTC"
vm_guest_os_family             = "windows"
vm_guest_os_name               = "server"
vm_guest_os_version            = "2025"
vm_guest_os_edition_standard   = "standard"
vm_guest_os_edition_datacenter = "datacenter"
vm_guest_os_experience_core    = "core"
vm_guest_os_experience_desktop = "dexp"

// Virtual Machine Guest Operating System Setting
// Note that for 2022 servers the OS type still specifies 2019,
// but uses the 'next' keyword to indicate 2022.
vm_guest_os_type = "windows2022srvNext_64Guest"

// Virtual Machine Hardware Settings
vm_firmware              = "efi-secure"
vm_cdrom_type            = "sata"
// vm_cpu_sockets is equivalent
// to the amount of vCPU's assigned
// to an instance. This name
// differs from upstream.
vm_cpu_sockets           = 16
vm_cpu_cores             = 1
vm_cpu_hot_add           = false
vm_mem_size              = 12288
vm_mem_hot_add           = false
vm_disk_size             = 40000
vm_disk_controller_type  = ["pvscsi"]
vm_disk_thin_provisioned = true
vm_network_card          = "vmxnet3"

// Removable Media Settings
// Note that these are specific
// to the current vSphere environment,
// and should changed when ISOs are uploaded
// or removed
iso_path           = "ISOs"
iso_file           = "windows_2025_nov.iso"
iso_checksum_type  = "sha256"
iso_checksum_value = "d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d"

// Boot Settings
vm_boot_order       = "disk,cdrom"
vm_boot_wait        = "2s"
vm_boot_command     = ["<spacebar>"]
// The unattend.xml file used here (sysprep_unattend.pkrtpl.hcl) differs from the initial unattend.xml file (autounattend.xml)
vm_shutdown_command = "C:\\Windows\\system32\\Sysprep\\sysprep.exe /generalize /shutdown /oobe /mode:vm /unattend:C:\\autounattend.xml"

// Communicator Settings
communicator_port    = 5985
communicator_timeout = "12h"

// Provisioner Settings
preparationScripts = ["scripts/windows/windows-prepare.ps1"]
finishScripts = ["scripts/windows/windows-finish.ps1"]
