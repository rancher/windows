# Active Directory Applications in Kubernetes

## Why use gMSAs in Kubernetes?

You want to deploy your internal, containerized applications across Windows machines for **scalability and fault-tolerance**, in case one of the machines goes down or you experience increased load.

## Initial Setup

First, a user needs to perform the **one-time actions** performed by a system administrator in each domain identified in the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#gmsa-architecture-and-improvements), including:

1. Generating a KDC key on your Active Directory setup to allow it to use gMSAs
2. Creating gMSAs and impersonation account(s) in Active Directory

You will also need to install a CCG Plugin onto your cluster (such as the [Rancher CCGRKC solution](./05_rancher_ccgrkc_plugin.md)) so that each node that needs to schedule gMSA workloads can get the credentials it needs.

## Installing gMSA webhook

After initial setup, users should install [the gMSA webhook chart](https://github.com/kubernetes-sigs/windows-gmsa) maintained by [SIG Windows](https://github.com/kubernetes/community/blob/master/sig-windows/README.md). The Rancher Windows team also maintains a copy of this chart that is available on Rancher's Apps & Marketplace.

This webhook makes it easier to automatically populate the `spec.securityContext.windowsOptions.gmsaCredentialSpec` in gMSA workloads by pointing `spec.securityContext.windowsOptions.gmsaCredentialSpecName` at a `GMSACredentialSpec` CR.

The webhook replicates the content of the CR into `spec.securityContext.windowsOptions.gmsaCredentialSpec`.

> **Note**: By default, the webhook's [failure policy](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#failure-policy) is `Fail`.
>
> This means that if the webhook is down, any `CREATE` operations on `Pod` resources will fail.
>
> This creates a "chicken and egg" situation since, if the webhook is down, you cannot create a new Pod for the webhook since the webhook is not available.
>
> To avoid this, Rancher's copy of the webhook includes a `ValidatingWebhookConfiguration` that disables running the webhook on its own release namespace using `.webhooks[0].namespaceSelector.matchExpressions`.

## Creating a `GMSACredentialSpec`

After installing the webhook, a new custom resource definition called a `GMSACredentialSpec` will be available in your cluster.

The spec of this resource matches the content that you would pass in to a container runtime as a `CredentialSpec`.

You will need to create one `GMSACredentialSpec` resource per `gMSA` that you would like to add to the cluster; it's generally recommend that each independent workload in your cluster should use a different `gMSA`.

> **Note**: The `GMSACredentialSpec` is a **global** resource, which means that it does not belong to a namespace.

For example, it may look like this:

```yaml
apiVersion: auth.k8s.io/v1alpha1
kind: GMSACredentialSpec
metadata:
  name: webapp-gmsa
  namespace: cattle-wins-system
spec:
  credspec:
    ActiveDirectoryConfig:
      GroupManagedServiceAccounts:
        - Name: "webapp-gmsa"
          Scope: "example.com"
    # If you are using a CCG Plugin like CCGRKC:
    # HostAccountConfig:
    #   PortableCcgVersion: "1"
    #   PluginGUID: "{e4781092-f116-4b79-b55e-28eb6a224e26}"
    #   PluginInput: "cattle-wins-system:webapp-gmsa-impersonation-account"
    DomainJoinConfig:
      Sid: "S-1-5-21-3623811015-3361044348-30300820"
      MachineAccountName: "webapp-gmsa"
      Guid: "bf3f2e6e-8a3c-4f7a-8d0f-9e389e6d3333"
      DnsName: "example.com"
      NetBiosName: "EXAMPLE"
    CmsPlugins:
      - ActiveDirectory
```

## Create a gMSA workload

Identify the `GMSACredentialSpec` that your workload will use under `spec.securityContext.windowsOptions.gmsaCredentialSpecName`.

Make sure that the service account tied to the workload has RBAC permissions that enable it to `use` the `GMSACredentialSpec`.

Once that's done, you should have a gMSA workload up and running in your cluster!
