# Group Managed Service Accounts (gMSAs)

## What is a Service Account

A [service account](https://en.wikipedia.org/wiki/Service_account) is an **identity** assigned to an application or service that allows it to interact with other applications.

While the idea behind a service account is consistent across platforms, different platforms have different ways of assigning applications identity.

For example:

- In Windows, [service accounts](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-service-accounts) provide a security context for services that are specifically running on Windows operating systems
- In Kubernetes, [service accounts](https://kubernetes.io/docs/concepts/security/service-accounts/) are objects in the cluster that represent identities for application pods or system components
- In AWS, a similar concept of a [service principal](https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-structure.html#intro-structure-principal) exists that grants a workload permission to make certain requests to AWS.

## Why do we need service accounts?

Let's say that you have an internal application that needs special permissions to run (i.e. needs to be able to make requests to Active Directory).

You could start this application by having an **authorized user** run the application using **their own credentials**.

But with this approach, there is a link between the user and the application; if the user loses certain permissions (or if you remove the user from the organization), it could break all internal applications deployed in this way.

With service accounts, as long as an authorized user **starts** the service that uses a service account, the application is no longer reliant on the user who started it; it will use the service account's authorizations.

## Windows Service Accounts

In the Windows world, there are two types of service accounts for running applications offered by Active Directory:

1. **[Standalone Managed Service Accounts (sMSAs)](https://learn.microsoft.com/en-us/entra/architecture/service-accounts-standalone-managed)**
2. **[Group Managed Service Accounts (gMSAs)](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview)**

Both service accounts have the same benefits, namely:

- Automatic password management by the Windows OS
- Simplified service principal name (SPN) management
- Ability to delegate management to other administrators

The primary difference between these two types of accounts is that you **cannot reuse sMSAs across servers**.

Since computers can use a single gMSA simultaneously, any application that is load balanced across servers (i.e. workloads managed by a container orchestrator like [Kubernetes](https://kubernetes.io/)) will typically use gMSAs, since replicas of the application can all use the same gMSA to make requests.

## How do gMSAs work?

### Why are they used?

Since each gMSA belongs to a specific Active Directory domain, gMSAs are typically used for running services that interact with other services within the Active Directory domain.

For example, one common use case for gMSAs is when developing applications that communicate with **Microsoft SQL Server** or other domain services that require some form of AD-based authentication.

For Microsoft SQL Server, an example application would be one that performs some sort of continuous maintenance or analysis on the database.

### Authentication FLow

The authentication flow for using gMSAs typically leverages [Integrated Windows Authentication](https://learn.microsoft.com/en-us/aspnet/web-api/overview/security/integrated-windows-authentication), which typically involves uses [Kerberos Authentication](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview).

On a high-level, here are the steps involved:

1. The host / application contacts an Active Directory [Domain Controller (DC)](../domain_controllers.md) tied to the domain that the gMSA belongs in for the gMSA's password
2. The DC contacts a domain service known as the [Key Distribution Center (KDC)](https://learn.microsoft.com/en-us/windows/win32/secauthn/key-distribution-center), which uses Active Directory's database as its security account database.
3. The KDC uses a **root key** to create a key. The DC uses this key to **dynamically** generate the gMSA's password for the host / application.

Once the host / application has the gMSA's password:

1. The host / application issues a request with the gMSA's password to the KDC's [Authentication Service (AS)](https://learn.microsoft.com/en-us/windows/win32/secauthn/key-distribution-center), which issues a **ticket-granting ticket (TGT)**.
2. The host / application issues a request with the TGT to the domain's **Ticket-Granting Service (TGS)**, which issues a **ticket** to the application.

Once the application acquires a ticket, it can present that ticket as a form of authenticating as that gMSA within the Active Directory domain.

> **Note**: Here are some security details (in no particular order):
>
> - The KDC integrates with other Windows Server security services that run on a DC.
> - The dynamically generated gMSA password is **never** stored on the DC.
> - The KDC root key is a highly privileged resource which is critical to securing the gMSA accounts; the root key generates the password for **all** gMSA accounts.
> - KDC periodically rotates the root key, which means that the password will auto-expire after a given period of time.
> - Hosts can contact the DC to get both the current and preceding gMSA password from the KDC.
> - Active Directory expects encryption methods to be uniform across all applications running on a domain, since all Domain Controllers will need to be able to independently compute the same gMSA password dynamically for a given duration.
> - Every DC must at least use [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard).
> - The TGT is also used as a user access token to request access token for other services. For more information on TGTs, see the [Microsoft docs](https://learn.microsoft.com/en-us/windows/win32/secauthn/ticket-granting-tickets).

## Using gMSAs in containerized environments

### Docker / containerd

[Docker](https://www.docker.com/) supports passing in gMSAs that containers should use within a **domain-joined host** by passing in a `--security-opt` flag.

By providing a value like `credentialspec=file://my_gmsa_creds.json` that points to a **[credential spec](../applications/03_containerizing_internal_applications.md#what-is-a-credential-spec)** file, Docker will ensure that the container will run using that gMSA.

Similar functionality exists in [`containerd`](https://containerd.io/).

### Kubernetes

In Kubernetes, you can similarly pass in the credential spec to pods by providing its contents in `.spec.securityContext.windowsOptions.gmsaCredentialSpec`.

For more information about this, see [the docs](../applications/04_deploying_internal_applications_to_kubernetes.md).

## Resources

To read more about gMSAs, please read the [Microsoft docs](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview).
