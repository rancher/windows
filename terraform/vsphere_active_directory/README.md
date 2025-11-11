## vSphere Active Directory

This module Stands up and configures an Active Directory instance within vSphere preconfigured for use with gMSA solutions.

### Usage

Create a copy of the `simple_gmsa.tfvarsexample` file and populate the relevant variables with values specific to your vSphere environment and desired Active Directory configuration. 

### Developing

This directory utilizes five PowerShell scripts to stand up and configure an Active Directory instance, these can be found in the `files` directory. If additional files need to be added to extend how Active Directory instances are created the following should be done: 

+ Add a new `.ps1` file in the `files` directory
+ Define a new script within `scripts.tf` and provide any template values needed
+ Add the new script to the VM by updating the scripts array within `main.tf`

### Integrating With The Active Directory Instance

Often applications which need to integrate with Active Directory instances require fairly obscure IDs and other details. This automation automatically creates a values.json file which contains many of the commonly required Active Directory details needed for integration (gMSA solutions, LDAP, etc.). This file can be found at `C:\etc\rancher-dev\active_directory\values.json` and can be retrieved using `scp`, redirected network drives, or simple copy and paste over RDP or SSH. 

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
