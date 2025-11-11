## vSphere server

This directory contains automation for standing up one or more VMs within a vSphere environment.

### Usage

Reference `examples/ubuntu.tfvarsexample` or `examples/windows_2022.tfvarsexample` as a reference for standing up servers. Create a copy of these example files and populate the required fields for the given vSphere environment.

### Additional Details

#### MS SQL Server Support

This module supports creating a VM preconfigured with an instance of Microsoft SQL Server. Some prerequisites must be met in order for this configuration to work 

+ An Active Directory instance must be created and defined within the `tfvars` file. The SQL server relies on AD for user authentication.
+ The VM should be configured with sufficient resources
  + 16vCPU, 32 GB RAM, >= 100GB diskspace

#### Custom Script Support

This module supports running arbitrary scripts on nodes during the provisioning process. The definition of a custom script list in this module can be found below, with key behavior differences between Linux and Windows described. 

```terraform
scripts = [
  {
    # Alternatively, the content can be sourced from a file using the `file` or `templatefile` functions
    content      = "Write-Host 'custom scripts work'"
    # Script destinations on linux which do not specify absolute paths are placed in '~'.
    # All Windows scripts are unconditionally placed in `C:\scripts`. On Windows, the .ps1 extension is required.
    destination  = "example1.ps1"
    # Specify any arguments that the script may require. 
    arguments    = "its true, they do"
    # 'execute' denotes if the script should be executed using `remote-exec`. 
    # Scripts which set execute to true will always run in parallel. 
    # Windows scripts should never set 'execute' to true. 
    # On Windows, an additional script is automatically created to properly sequence the execution of all script files.
    execute      = true
  }
]
```

For more information on how Windows handles the execution of script files, refer to `terraform/internal/vsphere/vm/files/add_scheduled_tasks.ps1`. 

#### Windows Script Bundles

By default, Windows does not ship common developer tooling that may be useful when debugging a cluster (Go, Git, sys-internals, etc.). To make setting up development nodes easier, a dedicated `windows_script_bundle` field can be defined when creating Windows VMs. Three possible values can be passed,

+ `debug`
  + The smallest bundle, `debug` installs the `scoop` package manager and low level tools such as `sys-internals`. 
+ `dev`
  + The recommended bundle, `dev` includes the `debug` bundle as well as additional tools such as `docker`
+ `advancedDev`
  + The largest bundle, `advancedDev` dev includes `dev` bundle, and also installs less commonly used OS features such as WSL2 and Hyper-V

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
