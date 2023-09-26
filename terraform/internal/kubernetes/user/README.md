# Users

This [Terraform](https://www.terraform.io/) module outputs a script that initializes a "user" (i.e. a TLS certificate corresponding to a signed certificate signing request encoded into a `KUBECONFIG` file) with `cluster-admin` permissions on a Kubernetes cluster.

Once this module has outputted a script, ensure that your exported `KUBECONFIG` environment variable points to a Kubernetes cluster before running it.

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
