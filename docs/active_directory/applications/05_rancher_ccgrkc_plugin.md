# [Rancher Kubernetes Cluster CCG Plugin (CCGRKC)](https://github.com/rancher/Rancher-Plugin-gMSA)

As a fully Kubernetes-native solution, the [Rancher Kubernetes Cluster CCG Plugin (CCGRKC)](https://github.com/rancher/Rancher-Plugin-gMSA) treats the Kubernetes cluster it runs on as the "secret store" it stores Active Directory credentials for impersonation accounts within.

As a result, there is **no strict dependency** on any external key storage service like Azure Key Vault or any underlying infrastructure provider used to provision hosts.

To install Rancher's CCG Cluster Plugin, **system administrators / cluster owners** need to install following Helm charts onto a **secure / locked-down** (system) namespace:

1. [`rancher-gmsa-plugin-installer`](rancher-ccg-dll-installer): a Helm chart that creates a `DaemonSet` to install the CCGRKC DLL onto all Windows hosts. Install this **once**.
2. [`rancher-gmsa-account-provider`](https://github.com/rancher/Rancher-Plugin-gMSA/tree/main/charts/rancher-gmsa-account-provider): a Helm chart that creates a `DaemonSet` that hosts an HTTPS server (known as the **Account Provider**) on each Windows host. Install this **once per impersonation account** that you would like nodes in the cluster to be able to access.

Once installed, a system administrator should place the credentials of the impersonation account in the release namespace and whose name matches the format `<rancher-gmsa-account-provider-release-name>-creds`.

After this, you can start scheduling Windows workloads that have `spec.template.spec.securityContext.windowsOptions.gmsaCredentialSpecName` pointing to a valid `GMSACredentialSpec`!

## How does it work?

On a high-level, the `rancher-gmsa-plugin-installer` installs a [dynamic link library (DLL)](https://learn.microsoft.com/en-us/troubleshoot/windows-client/deployment/dynamic-link-library) that `ccg.exe` invokes as a [COM+ component](../../COM/01-Introduction.md).

The `rancher-gmsa-account-provider` creates an HTTPS server (along with client and server certificates) on the host.

When `ccg.exe` invokes the DLL as part of the non-domain-joined process of authenticating a container with Active Directory, the DLL sends a request to the Account Provider, which retrieves credentials from the Kubernetes cluster and transform the response into the format expected by `ccg.exe`.

This allows `ccg.exe` to retrieve the gMSA credentials and inject them into the container on start.

## Why do I need to install one `rancher-gmsa-account-provider` Helm chart per impersonation account?

From a security perspective, this encourages a system of **least privilege** since system administrators can use **nodeSelectors** on the `rancher-gmsa-account-provider` workload as a security control for which nodes get access to Active Directory credentials.

> **Note**: To elaborate, the `DaemonSet` deployed by each `rancher-gmsa-account-provider` release can read a specific Secret in the release namespace named `<rancher-gmsa-account-provider-release-name>-creds`. It cannot read any other Secrets in that namespace (i.e. other impersonation account credentials).
>
> A user who has permissions to exec into a Windows host, exec into the `rancher-gmsa-account-provider` container, and make a request to the Kubernetes cluster by impersonating the container's service account credentials can access the contents of that one Secret. They cannot see any other Secrets.
>
> Once you remove the container from the host, a user who has permissions to exec into the Windows host can no longer access that Secret.

From a system administrator's perspective, deploying one Helm release per impersonation account also makes sense since realistically you will want one impersonation account per Active Directory domain.

## Security Model

To understand the security model, we can draw a parallel between the way that the CCGRKC plugin works and [the way the CCGAKV plugin works](./03_containerizing_internal_applications.md#example-azure-key-vault-ccg-plugin).

While the CCGAKV plugin invokes the Azure IMDS by accessing a defined endpoint (`http://169.254.169.254/metadata/identity/oauth2/token`), the CCGRKC plugin references **a set of files mounted on the host** by the `rancher-gmsa-account-provider` Pod that identify:

1. The **host port** that the `rancher-gmsa-account-provider` HTTPS server is listening on
2. The **client and server certificates** used to establish an [mTLS](HTTPS://en.wikipedia.org/wiki/Mutual_authentication) connection with it

The set of files mounted on the host in the CCGRKC implementation effectively represents the Azure IMDS in the CCGAKV implementation since both provide the **connection details used to talk to their respective "secret store"**.

On invocation, the DLL reaches out to the `rancher-gmsa-account-provider` HTTPS server, which can use its `ServiceAccount` credentials to **authenticate** itself to the Kubernetes API Server and retrieve the contents of the Kubernetes secret that contains the impersonation account's credentials (which it will be **authorized** to do via a `RoleBinding` attached to its `ServiceAccount`).

The HTTPS server in the CCGRKC implementation effectively represents Azure Key Vault in the CCGAKV implementation since both are **providers of the stored credentials** that you can authenticate with.

In CCGRKC, Active Directory implicitly trusts the application to perform authentication requests because it believes:

1. No host process except `ccg.exe` invokes the CCG Plugin DLL (and `ccg.exe` creates valid, user-requested containers that require gMSA credentials).

2. No host process except those who invoke the CCGRKC DLL **has access to the set of files mounted on the host** to authenticate against **the HTTPS server that authenticates and has the authorization to query the Secret in the Kubernetes cluster** to retrieve credentials.
