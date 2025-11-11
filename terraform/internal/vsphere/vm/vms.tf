terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

locals {
  template_id = var.image.template_path != "" ? data.vsphere_virtual_machine.template[0].id : (
    var.image.content_library != null ? data.vsphere_content_library_item.item[0].id : null
  )
  executable_scripts = local.all_scripts == null ? [] : [for script in local.all_scripts : script if script.execute]
}

data "vsphere_datacenter" "datacenter" {
  name = var.data_center
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.compute_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  count = var.image.template_path != "" ? 1 : 0
  name  = var.image.template_path
}

data "vsphere_content_library" "library" {
  count = var.image.content_library != null ? 1 : 0
  name  = var.image.content_library.library
}

data "vsphere_content_library_item" "item" {
  count      = var.image.content_library != null ? 1 : 0
  name       = var.image.content_library.item
  type       = "ovf"
  library_id = data.vsphere_content_library.library[0].id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.cpu_count
  memory           = var.memory_in_mb
  guest_id         = var.guest_id
  firmware         = var.os == "windows" ? "efi" : "bios"
  folder           = var.folder

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "Hard Disk 1"
    size  = var.disk_size
  }

  cdrom {
    client_device = true
  }

  dynamic "vapp" {
    for_each = var.connection_details.ssh_public_key_path != "" ? [1] : [0]
    content {
      properties = var.image.os == "linux" ? {
        "public-keys" = file(var.connection_details.ssh_public_key_path)
        "password"    = var.connection_details.password
      } : {}
    }
  }

  clone {
    template_uuid = local.template_id
  }
}

resource "null_resource" "standard-provisioner" {
  for_each = { for i, script in local.all_scripts : {
    key    = script.name
    script = script
    }.key => script if !script.execute
  }

  connection {
    type        = var.image.os == "windows" ? "winrm" : "ssh"
    user        = var.connection_details.username
    password    = var.connection_details.password
    private_key = var.connection_details.ssh_key_path != "" ? file(var.connection_details.ssh_key_path) : ""
    host        = vsphere_virtual_machine.vm.guest_ip_addresses[0]
  }

  provisioner "file" {
    content     = each.value.content
    destination = var.image.os == "windows" ? "C:\\scripts\\${each.value.name}" : "${each.value.name}"
  }
}

resource "null_resource" "executable-provisioner" {
  for_each   = { for i, script in local.executable_scripts : script.name => script }
  depends_on = [null_resource.standard-provisioner]

  connection {
    type        = var.image.os == "windows" ? "winrm" : "ssh"
    user        = var.connection_details.username
    password    = var.connection_details.password
    private_key = var.connection_details.ssh_key_path != "" ? file(var.connection_details.ssh_key_path) : ""
    host        = vsphere_virtual_machine.vm.guest_ip_addresses[0]
  }

  provisioner "file" {
    content = each.value.content
    # TODO: Identify if the Windows script name specifies an absolute path, and use that
    #       instead of forcing c:\scripts
    destination = var.image.os == "windows" ? "C:\\scripts\\${each.value.name}" : "${each.value.name}"
  }

  provisioner "remote-exec" {
    inline = [
      var.image.os == "windows" ?
      "powershell.exe -File C:\\scripts\\${each.value.name}" :
      "sh ${each.value.name}"
    ]
  }
}