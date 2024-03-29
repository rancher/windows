# windows-ad-setup

This is a simple Helm chart that deploys a couple of different components to integrate a Windows cluster with an Active Directory domain, including:

- A set of `GMSACredentialSpecs` corresponding to gMSAs on a domain
- An impersonation account `Secret` for the [Rancher gMSA CCG Plugin](https://github.com/rancher/Rancher-Plugin-gMSA)

## How To Use This Chart

This chart expects that you are using it in conjunction with the [`azure_active_directory` Terraform module](../../terraform/azure_active_directory) on this repository.

A `values.yaml` that for this chart is automatically generated by a script emitted by the Terraform module so that you can deploy this chart onto a downstream cluster to get it wired up with your provisioned Active Directory instance.

## Installing Manually

To install or upgrade this chart on a cluster, from the root of this repository, run the following command from a terminal that has your `KUBECONFIG` environment set up to point to your target Windows cluster:

```bash
VALUES_YAML_FILE="mycluster.values.yaml"
helm upgrade --install -n default windows-ad-setup -f ${VALUES_YAML_FILE} ./charts/windows-ad-setup
```

## State of Support

**The Rancher Windows team does not support this Helm chart in any official capacity.**

Community members should note this Helm chart is **never intended for use in any production environment** and is **subject to breaking changes at any point of time**.

The primary audience for this Helm chart is **members of the Rancher Windows team** who require this Helm chart to reproduce setups that mimic supported environments.
