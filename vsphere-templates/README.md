# VMware vSphere Packer and Terraform Templates for Rancher

> *Note*
> 
> This repository initially contained templates for Linux VMs. As they were not regularly used or tested, they have been removed. Refer to [packer-examples-for-vsphere](https://github.com/vmware-samples/packer-examples-for-vsphere) for a more up to date example of how to template linux VMs.


<img alt="VMware vSphere 7.0 Update 2+" src="https://img.shields.io/badge/VMware%20vSphere-7.0%20Update%202+-blue?style=for-the-badge">
<img alt="Packer 1.8.0+" src="https://img.shields.io/badge/HashiCorp%20Packer-1.8.0+-blue?style=for-the-badge&logo=packer">

## Table of Contents
1. [Introduction](#Introduction)
2. [Requirements](#Requirements)
3. [Configuration](#Configuration)
4. [Build](#Build)
5. [Troubleshoot](#Troubleshoot)
6. [Credits](#Credits)

## Introduction

*This project is a fork of the awesome [packer-examples-for-vsphere](https://github.com/vmware-samples/packer-examples-for-vsphere) repository on GitHub. It has been modified to better support configuration to work better with Rancher, RKE, and RKE2.*

This repository provides infrastructure-as-code examples to automate the creation of virtual machine images and their guest operating systems on VMware vSphere using [HashiCorp Packer][packer] and the [Packer Plugin for VMware vSphere][packer-plugin-vsphere] (`vsphere-iso`). All examples are authored in the HashiCorp Configuration Language ("HCL2").

Use of this project is mentioned in the **_VMware Validated Solution: Private Cloud Automation for VMware Cloud Foundation_** authored by the maintainer. Learn more about this solution at [vmware.com/go/vvs](https://vmware.com/go/vvs).

By default, the machine image artifacts are transferred to a [vSphere Content Library][vsphere-content-library] as an OVF template and the temporary machine image is destroyed. If an item of the same name exists in the target content library, Packer will update the existing item with the new version of OVF template.

The following builds are available:

**Microsoft Windows** - _Core and Desktop Experience_
* Microsoft Windows Server 2022 - Standard and Datacenter
* Microsoft Windows Server 2019 - Standard and Datacenter

## Requirements

**Packer**:
* HashiCorp [Packer][packer-install] 1.8.0 or higher.
* HashiCorp [Packer Plugin for VMware vSphere][packer-plugin-vsphere] (`vsphere-iso`) 1.0.3 or higher.
* [Packer Plugin for Windows Updates][packer-plugin-windows-update] 0.14.0 or higher - a community plugin for HashiCorp Packer.

    > Required plugins are automatically downloaded and initialized when using `./build.sh`. For dark sites, you may download the plugins and place these same directory as your Packer executable `/usr/local/bin` or `$HOME/.packer.d/plugins`.

**Operating Systems**:
* openSUSE Tumbleweed
* Ubuntu Server 20.04 LTS
* macOS

**Additional Software Packages**:

The following software packages must be installed on the Packer host:

* [Git][download-git] command-line tools.
  - openSUSE: `zypper install git`
  - Ubuntu: `apt-get install git`
  - macOS: `brew install git`
* A command-line .iso creator. Packer will use one of the following:
  - **xorriso** on openSUSE: `zypper install xorriso`
  - **mkisofs** on openSUSE: `zypper install mkisofs`
  - **xorriso** on Ubuntu: `apt-get install xorriso`
  - **mkisofs** on Ubuntu: `apt-get install mkisofs`
  - **hdiutil** on macOS: native
* mkpasswd
  - openSUSE: `zypper install whois`
  - Ubuntu: `apt-get install whois`
  - macOS: `brew install --cask docker`
* Coreutils
  - macOS: `brew install coreutils`
* HashiCorp [Terraform][terraform-install] 1.1.7 or higher and [Packer][packer-install] 1.8.0 or higher.
  - openSUSE:
    - `sudo zypper refresh && sudo zypper install -y gpg2 curl`
    - `sudo rpm --import https://rpm.releases.hashicorp.com/gpg`
    - `sudo zypper ar  https://rpm.releases.hashicorp.com/RHEL/35/x86_64/stable hashicorp`
    - `sudo zypper refresh && zypper install terraform packer`
  - Ubuntu:
    - `sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl`
    - `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`
    - `sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`
    - `sudo apt-get update && sudo apt-get install terraform packer`
  - macOS:
    - `brew tap hashicorp/tap`
    - `brew install hashicorp/tap/terraform`
* [Gomplate](gomplate-install) 3.10.0 or higher.
  - Only required if you are updating build.tmpl and build.sh 
  - openSUSE:
    - `sudo curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/<version>/gomplate_<os>-<arch>`
    - `sudo chmod 755 /usr/local/bin/gomplate`
  - Ubuntu:
    - `sudo curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/<version>/gomplate_<os>-<arch>`
    - `sudo chmod 755 /usr/local/bin/gomplate`
  - macOS:
    - `brew install gomplate`

**Platform**:
* VMware Cloud Foundation 4.2 or higher, or
* VMware vSphere 7.0 Update 2 or higher

## Configuration

The directory structure of the repository.

```console
├── build.sh
├── build.tmpl
├── build.yaml
├── config.sh
├── set-envvars.sh
├── README.md
├── builds
│   ├── build.pkvars.hcl.example
│   ├── common.pkvars.hcl.example
│   ├── proxy.pkvars.hcl.example
│   ├── vsphere.pkvars.hcl.example
│   └── windows
│       └── <distribution>
│           └── <version>
│               ├── *.pkr.hcl
│               ├── *.auto.pkrvars.hcl
│               └── data
│                   └── autounattend.pkrtpl.hcl
├── certificates
│   └── root-ca.cer.example
├── manifests
├── scripts
│   └── windows
│       └── *.ps1
└── terraform
    │── vsphere-role
    └── vsphere-virtual-machine
```

The files are distributed in the following directories.
* **`builds`** - contains the templates, variables, and configuration files for the machine image build.
* **`scripts`** - contains the scripts to initialize and prepare a Windows machine image build.
* **`certificates`** - contains the Trusted Root Authority certificates for a Windows machine image build.
* **`manifests`** - manifests created after the completion of the machine image build.
* **`terraform`** - contains example Terraform plans to test machine image builds.

> ⚠️ **WARNING**:
>
> While maintaining these templates, you **MUST** ensure that you do not commit sensitive information, such as passwords, keys, certificates, etc.

### Step 2 - Download the Guest Operating Systems ISOs

1. Download the x64 guest operating system [.iso][iso] images.

    **Microsoft Windows**
    * Microsoft Windows Server 2022
      * [Download](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019) the latest Evaluation edition of Windows Server 2019
    * Microsoft Windows Server 2019
      * [Download](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022) the latest Evaluation edition of Windows server 2022

3. Obtain the checksum type (_e.g._ `sha256`, `md5`, etc.) and checksum value for each guest operating system `.iso` image from the vendor. This will be use in the build input variables.

4. [Upload][vsphere-upload] your guest operating system `.iso` images to the ISO datastore and paths that will be used in your variables.

    **Example**: `config/common.pkvars.hcl`

    ```hcl
    common_iso_datastore = "sfo-w01-cl01-ds-nfs01"
    iso_path             = "iso/linux/photon"
    iso_file             = "photon-4.0-xxxxxxxxx.iso"
    iso_checksum_type    = "md5"
    iso_checksum_value   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ```

### Step 3 - Configure Service Account Privileges in vSphere

Create a custom vSphere role with the required privileges to integrate HashiCorp Packer with VMware vSphere. A service account can be added to the role to ensure that Packer has least privilege access to the infrastructure. Clone the default **Read-Only** vSphere role and add the following privileges:

Category        | Privilege                                           | Reference
----------------|-----------------------------------------------------|---------
Content Library | Add library item                                    | `ContentLibrary.AddLibraryItem`
 ...            | Update Library Item                                 | `ContentLibrary.UpdateLibraryItem`
Datastore       | Allocate space                                      | `Datastore.AllocateSpace`
...             | Browse datastore                                    | `Datastore.Browse`
...             | Low level file operations                           | `Datastore.Browse`
Network         | Assign network                                      | `Network.Assign`
Resource        | Assign virtual machine to resource pool             | `Resource.AssignVMToPool`
vApp            | Export                                              | `vApp.Export`
Virtual Machine | Configuration > Add new disk                        | `VirtualMachine.Config.AddNewDisk`
...             | Configuration > Add or remove device                | `VirtualMachine.Config.AddRemoveDevice`
...             | Configuration > Advanced configuration              | `VirtualMachine.Config.AdvancedConfig`
...             | Configuration > Change CPU count                    | `VirtualMachine.Config.CPUCount`
...             | Configuration > Change memory                       | `VirtualMachine.Config.Memory`
...             | Configuration > Change settings                     | `VirtualMachine.Config.Settings`
...             | Configuration > Change Resource                     | `VirtualMachine.Config.Resource`
...             | Configuration > Set annotation                      | `VirtualMachine.Config.Annotation`
...             | Edit Inventory > Create from existing               | `VirtualMachine.Inventory.CreateFromExisting`
...             | Edit Inventory > Create new                         | `VirtualMachine.Inventory.Create`
...             | Edit Inventory > Remove                             | `VirtualMachine.Inventory.Delete`
...             | Interaction > Configure CD media                    | `VirtualMachine.Interact.SetCDMedia`
...             | Interaction > Configure floppy media                | `VirtualMachine.Interact.SetFloppyMedia`
...             | Interaction > Connect devices                       | `VirtualMachine.Interact.DeviceConnection`
...             | Interaction > Inject USB HID scan codes             | `VirtualMachine.Interact.PutUsbScanCodes`
...             | Interaction > Power off                             | `VirtualMachine.Interact.PowerOff`
...             | Interaction > Power on                              | `VirtualMachine.Interact.PowerOn`
...             | Provisioning > Create template from virtual machine | `VirtualMachine.Provisioning.CreateTemplateFromVM`
...             | Provisioning > Mark as template                     | `VirtualMachine.Provisioning.MarkAsTemplate`
...             | Provisioning > Mark as virtual machine              | `VirtualMachine.Provisioning.MarkAsVM`
...             | State > Create snapshot                             | `VirtualMachine.State.CreateSnapshot`

**Global permissions are required for the content library.** For example:

1. Log in to the vCenter Server at _<management_vcenter_server_fqdn>/ui_ as `administrator@vsphere.local`.
2. Select **Menu** > **Administration**.
3. In the left pane, select **Access control** > **Global permissions** and click the **Add permissions** icon.
4. In the **Add permissions** dialog box, enter the service account (_e.g._ svc-packer-vsphere@rainpole.io), select the custom role (_e.g._ Packer to vSphere Integration Role) and the **Propagate to children** check box, and click OK.

In an environment with many vCenter Server instances, such as management and workload domains, you may wish to further reduce the scope of access across the infrastructure in vSphere for the service account. For example, if you do not want Packer to have access to your management domain, but only allow access to workload domains:

1. From the **Hosts and clusters** inventory, select management domain vCenter Server to restrict scope, and click the **Permissions** tab.
2. Select the service account with the custom role assigned and click the **Change role** icon.
3. In the **Change role** dialog box, from the **Role** drop-down menu, select **No Access**, select the **Propagate to children** check box, and click **OK**.

### Step 4 - Configure the Variables

The [variables][packer-variables] are defined in `.pkvars.hcl` files.

#### **Copy the Example Variables**

Run the config script `./config.sh` to copy the `.pkvars.hcl.example` files to the `config` directory.

> ⚠️ **WARNING**:
> 
> The directory created by config.sh will contain sensitive information relating to your vSphere environment. You **MUST** ensure that the contents of that directory are **_NEVER_** committed or publicly exposed.

While the `config` folder is the default folder, you may override the default by passing an alternate value as the first argument.

```console
./config.sh config/foo
./build.sh config/foo
```

For example, this is useful for the purposes of running machine image builds for different environments.

**San Francisco:** us-west-1

```console
./config.sh config/us-west-1
./build.sh config/us-west-1
```

**Los Angeles:** us-west-2

```console
./config.sh config/us-west-2
./build.sh config/us-west-2
```

##### Build Variables

Edit the `config/build.pkvars.hcl` file to configure the following:

* Credentials for the default account on machine images.

**Example**: `config/build.pkvars.hcl`

```hcl
build_username           = "rainpole"
build_password           = "<plaintext_password>"
build_password_encrypted = "<sha512_encrypted_password>"
build_key                = "<public_key>"
```
You can also override the `build_key` value with contents of a file, if required.

For example:

```hcl
build_key = file("${path.root}/config/ssh/build_id_ecdsa.pub")
```

Generate a SHA-512 encrypted password for the `build_password_encrypted` using tools like mkpasswd.

**Example**: mkpasswd using Docker on macOS:

```console
rainpole@macos>  docker run -it --rm alpine:latestvmwar mkpasswd -m sha512
Password: ***************
[password hash]
```

**Example**: mkpasswd on Linux:

```console
rainpole@linux>  mkpasswd -m sha-512
Password: ***************
[password hash]
```
Generate a public key for the `build_key` for public key authentication.

**Example**: macOS and Linux.

```console
rainpole@macos> cd .ssh/
rainpole@macos ~/.ssh> ssh-keygen -t ecdsa -b 521 -C "code@rainpole.io"
Generating public/private ecdsa key pair.
Enter file in which to save the key (/Users/rainpole/.ssh/id_ecdsa):
Enter passphrase (empty for no passphrase): **************
Enter same passphrase again: **************
Your identification has been saved in /Users/rainpole/.ssh/id_ecdsa.
Your public key has been saved in /Users/rainpole/.ssh/id_ecdsa.pub.
```

The content of the public key, `build_key`, is added the key to the `.ssh/authorized_keys` file of the `build_username` on the guest operating system.

##### Common Variables

Edit the `config/common.pkvars.hcl` file to configure the following common variables:

* Virtual Machine Settings
* Template and Content Library Settings
* Removable Media Settings
* Boot and Provisioning Settings

**Example**: `config/common.pkvars.hcl`

```hcl
// Virtual Machine Settings
common_vm_version           = 19
common_tools_upgrade_policy = true
common_remove_cdrom         = true

// Template and Content Library Settings
common_template_conversion     = false
common_content_library_name    = "sfo-w01-lib01"
common_content_library_ovf     = true
common_content_library_destroy = true

// Removable Media Settings
common_iso_datastore = "sfo-w01-cl01-ds-nfs01"

// Boot and Provisioning Settings
common_data_source      = "http"
common_http_ip          = null
common_http_port_min    = 8000
common_http_port_max    = 8099
common_ip_wait_timeout  = "20m"
common_shutdown_timeout = "15m"
```

##### Data Source Options

`http` is the default provisioning data source for machine image builds.

You can change the `common_data_source` from `http` to `disk` to build supported machine images without the need to use Packer's HTTP server. This is useful for environments that may not be able to route back to the system from which Packer is running.

The `cd_content` option is used when selecting `disk` unless the distribution does not support a secondary CD-ROM. For distributions that do not support a secondary CD-ROM the `floppy_content` option is used.

```hcl
common_data_source = "disk"
```

##### HTTP Binding

If you need to define a specific IPv4 address from your host for Packer's HTTP Server, modify the `common_http_ip` variable from `null` to a `string` value that matches an IP address on your Packer host. For example:

```hcl
common_http_ip = "172.16.11.254"
```

##### Proxy Variables (Optional)

Edit the `config/proxy.pkvars.hcl` file to configure the following:

* SOCKS proxy settings used for connecting to Linux machine images.
* Credentials for the proxy server.

**Example**: `config/proxy.pkvars.hcl`

```hcl
communicator_proxy_host     = "proxy.rainpole.io"
communicator_proxy_port     = 1080
communicator_proxy_username = "rainpole"
communicator_proxy_password = "<plaintext_password>"
```

##### vSphere Variables

Edit the `builds/vsphere.pkvars.hcl` file to configure the following:

* vSphere Endpoint and Credentials
* vSphere Settings

**Example**: `config/vsphere.pkvars.hcl`

```hcl
vsphere_endpoint             = "sfo-w01-vc01.sfo.rainpole.io"
vsphere_username             = "svc-packer-vsphere@rainpole.io"
vsphere_password             = "<plaintext_password>"
vsphere_insecure_connection  = true
vsphere_datacenter           = "sfo-w01-dc01"
vsphere_cluster              = "sfo-w01-cl01"
vsphere_datastore            = "sfo-w01-cl01-ds-vsan01"
vsphere_network              = "sfo-w01-seg-dhcp"
vsphere_folder               = "sfo-w01-fd-templates"
```
#### **Using Environment Variables**

Alternatively, you can set your environment variables if you would prefer not to save sensitive potentially information in cleartext files. You can add these to environmental variables using the included `set-envvars.sh` script:

```console
rainpole@macos> . ./set-envvars.sh
```

> **NOTE**: You need to run the script as source or the shorthand "`.`".

#### **Machine Image Variables**

Edit the `*.auto.pkvars.hcl` file in each `builds/<type>/<build>` folder to configure the following virtual machine hardware settings, as required:

* CPU Sockets `(int)`
* CPU Cores `(int)`
* Memory in MB `(int)`
* Primary Disk in MB `(int)`
* .iso Path `(string)`
* .iso File `(string)`
* .iso Checksum Type `(string)`
* .iso Checksum Value `(string)`

    >**Note**: All `variables.auto.pkvars.hcl` default to using the [VMware Paravirtual SCSI controller][vmware-pvscsi] and the [VMXNET 3][vmware-vmxnet3] network card device types.


### Step 5 - Modify the Configurations (Optional)

If required, modify the configuration files for Microsoft Windows.

#### Microsoft Windows Unattended and Scripts

Variables are passed into the [Microsoft Windowsunattend files (`autounattend.xml`)][microsoft-windows-unattend] as Packer template files (`autounattend.pkrtpl.hcl`) to generate these on-demand. Unattend files are used to automatically configure Windows on initial bootup. This includes setting up user profiles, defining the language and timezone, and many other options that would normally be configured in the Windows UI on initial boot of the OS. 

By default, each unattended file is set to use the [KMS client setup keys][microsoft-kms] as the **Product Key**. **If you are using an Evaluation edition of Windows server, a valid product key is not required.** 

**Need help customizing the configuration files?**

* **Microsoft Windows** - Use the Microsoft Windows [Answer File Generator][microsoft-windows-afg] if you need to customize the provided examples further.
  * Additionally, refer to the CloudBase Init documentation on specifics relating to how each VM created from a Windows template is personalized and made unique.   

### Step 6 - Add Certificates

Save a copy of your PEM encoded Root Certificate Authority certificate to the following in `.cer` format.
- `/certificates` for Windows machine images.

These files are copied to the guest operating systems and added the certificate to the Trusted Certificate Authority of the guest operating system. Windows still uses the shell provisioner at this time.

## Build

### Generate a Custom Build Script

The build script (`./build.sh`) can be generated using a template (`./build.tmpl`) and a configuration file in YAML (`./build.yaml`).

Generate a custom build script:

```console
rainpole@macos> gomplate -c build.yaml -f build.tmpl -o build.sh
```

### Build with Variables Files

Start a build by running the build script (`./build.sh`). The script presents a menu the which simply calls Packer and the respective build(s).

You can also start a build based on a specific source for some of the virtual machine images.

For example, if you simply want to build a Microsoft Windows Server 2022 Standard Core, run the following:

Initialize the plugins:

```console
rainpole@macos> packer init builds/windows/server/2022/.
```

Build a specific machine image:

```console
rainpole@macos> packer build -force \
      --only vsphere-iso.windows-server-standard-core \
      -var-file="config/vsphere.pkrvars.hcl" \
      -var-file="config/build.pkrvars.hcl" \
      -var-file="config/common.pkrvars.hcl" \
      builds/windows/server/2022
```

### Build with Environmental Variables

Initialize the plugins:

```console
rainpole@macos> packer init builds/windows/server/2022/.
```

Build a specific machine image using environmental variables:

```console
rainpole@macos> packer build -force \
      --only vsphere-iso.windows-server-standard-core \
      builds/windows/server/2022
```

Happy building!!!

## Troubleshoot

* Read [Debugging Packer Builds][packer-debug].

## Credits
* Owen Reynolds [@OVDamn][credits-owen-reynolds-twitter]

    [VMware Tools for Windows][credits-owen-reynolds-github] installation PowerShell script.

[//]: Links

[cloud-init]: https://cloudinit.readthedocs.io/en/latest/
[credits-owen-reynolds-twitter]: https://twitter.com/OVDamn
[credits-owen-reynolds-github]: https://github.com/getvpro/Build-Packer/blob/master/Scripts/Install-VMTools.ps1
[download-git]: https://git-scm.com/downloads
[gomplate-install]: https://gomplate.ca/
[hashicorp]: https://www.hashicorp.com/
[iso]: https://en.wikipedia.org/wiki/ISO_image
[microsoft-kms]: https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys
[microsoft-windows-afg]: https://www.windowsafg.com
[microsoft-windows-autologon]: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-password-value
[microsoft-windows-unattend]: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/
[packer]: https://www.packer.io
[packer-debug]: https://www.packer.io/docs/debugging
[packer-install]: https://www.packer.io/intro/getting-started/install.html
[packer-plugin-vsphere]: https://www.packer.io/docs/builders/vsphere/vsphere-iso
[packer-plugin-windows-update]: https://github.com/rgl/packer-plugin-windows-update
[packer-variables]: https://www.packer.io/docs/templates/hcl_templates/variables
[ssh-keygen]:https://www.ssh.com/ssh/keygen/
[terraform-install]: https://www.terraform.io/docs/cli/install/apt.html
[vmware-pvscsi]: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.hostclient.doc/GUID-7A595885-3EA5-4F18-A6E7-5952BFC341CC.html
[vmware-vmxnet3]: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-AF9E24A8-2CFA-447B-AC83-35D563119667.html
[vsphere-api]: https://code.vmware.com/apis/968
[vsphere-content-library]: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-254B2CE8-20A8-43F0-90E8-3F6776C2C896.html
[vsphere-guestosid]: https://vdc-download.vmware.com/vmwb-repository/dcr-public/b50dcbbf-051d-4204-a3e7-e1b618c1e384/538cf2ec-b34f-4bae-a332-3820ef9e7773/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
[vsphere-efi]: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.security.doc/GUID-898217D4-689D-4EB5-866C-888353FE241C.html
[vsphere-upload]: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.storage.doc/GUID-58D77EA5-50D9-4A8E-A15A-D7B3ABA11B87.html?hWord=N4IghgNiBcIK4AcIHswBMAEAzAlhApgM4gC+QA
[vsphere-tpm]: https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.vm_admin.doc/GUID-4DBF65A4-4BA0-4667-9725-AE9F047DE00A.html
