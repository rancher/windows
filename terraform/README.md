# Terraform For Rancher Windows Developers

This directory contains [Terraform](https://www.terraform.io/) modules that produce Rancher Windows development environments.

## Directory Structure

Each module rooted at this directory is a Terraform module that can be **independently** used to produce **a component within a development environment** (i.e. a [Windows or Linux server](./server/), [Docker-based Rancher setup](./rancher/), or [Rancher custom cluster](./cluster/)).

The only special subdirectory is [`internal/`](./internal/), which contains the underlying Terraform "library" modules that are referenced by all "external" Terraform modules to produce the underlying Terraform resources.

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
