# Images Terraform

This [Terraform](https://www.terraform.io/) module outputs the images used to spin up servers across all cloud providers supported by the Rancher Windows team.

## Checking supported images

To see supported images per cloud provider, run the following command at the root of this repository:

```bash
terraform -chdir=terraform/images plan
```

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
