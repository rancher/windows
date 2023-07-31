# Active Directory

## What is Active Directory?

Active Directory is a **directory service** built by Microsoft.

> **Note**: A directory service is one that stores a **catalog** of all resources (namely, user accounts, groups, and technical resources like computers or printers) owned by a single organization grouped / organized in a directory structure (i.e. like the files and folders on a computer).

In most enterprises that use Active Directory, it is managed by **system administrators** (i.e. IT professionals, as opposed to application developers).

## Why use Active Directory (or any directory service)?

Imagine if a CEO of a new company acquires some technical resources (i.e. laptops, servers, printers, etc.) for the first time and needs to distribute those resources to various individuals in the company (i.e. employees that need laptops for things like Outlook, Microsoft Office, etc.).

As an aspiring enterprise, this CEO would hire a system administrator / IT department to manage these resources.

As a system administrator who is tasked with this, you would probably start by doing three things:

1. Come up with an organizational chart of all individuals who are part of this company and where they fall under the company hierarchy (i.e. which organization or team this individual is a part of)

2. Distribute technical resources to these individuals and maintain something that keeps track of them

3. Identify how you can apply specific **policies / authorizations** to the distributed resources for security / compliance purposes (i.e. give most users the lowest possible privileges that can be granted on provided laptops, but assign the application development team admin privileges over their laptops)

Once you do this, you'll also need to make sure that **rolling maintenance work** is manageable (i.e. keeping track of resources when individuals leave a company, updating policies when existing individuals in a company are promoted / demoted / change roles, etc.).

### Using any directory service

Any directory service helps solve the first two tasks.

It allows you to define your organizational chart and keep track of technical resources by:

1. Adding or removing individuals in your organization as **users** within a directory

2. Defining roles (like application developer) as **groups** within a directory that users can be added and removed from

3. Adding technical resources (also known as network resources) within a directory

4. Creating multiple independent directories that can contain users, groups, technical resources, or other directories to represent organizational structures (i.e. Finance v.s. Engineering)

### Using Active Directory

As a directory service, Active Directory's specific advantage is its built-in support for allowing system administrators to manage the permissions / authorizations on **Windows computers**.

The process of adding a Windows computer to Active Directory is known as **domain joining**.

> **Note**: To understand why adding a computer to Active Directory is known as **domain joining**, it's important to understand how Active Directory organizes users, groups, and technical resources.
>
> To do this, we'll draw an analogy between Active Directory and any Windows computer.
>
> If your computer represents a **domain** in Active Directory, files on your computer represent each **user, group, or technical resource** tracked by a domain.
>
> **Organizational units** in Active Directory represent directories on your computer; while all the files still exist on your computer, they are simply **organized** using directories on your filesystem.
>
> While a single computer (domain) may be sufficient for some organizations, one concern a system administrator may have is that anyone who logs into the computer (i.e. anyone who has access to the domain) will be able to see all files and directories, so you may not want to put all of your files in one location. You may want to have multiple computers (domains)!
>
> In Active Directory, multiple computers (domains) are represented by a **forest**.

Domain-joined Windows computers directly use Active Directory to authenticate users.

On a logon attempt, the computer will pass the provided credentials to Active Directory to **authenticate** the user as one who exists in the same domain and identify the **authorizations** that this particular user has (i.e. does the user have permission to log in? Should they have admin privileges? etc.).

> **Note**: The [security controls](https://en.wikipedia.org/wiki/Security_controls) offered to system administrators for domain-joined Windows machines can be extremely granular.
>
> For example, you can even control things like "allow access to certain sections of the Windows control panel" or "make sure every computer's main page is set to this URL".

### Managing Organizational Changes

In a domain-joined host, since the computer is configured to reach out to Active Directory to authenticate users every time, **rolling changes applied by system administrators to the organization are automatically applied to all technical resources tracked by Active Directory**.

For example, if a system administrator changes the permissions of the user on Active Directory, they will no longer be able to log into their laptop since the laptop will reach out to Active Directory for authentication, which may no longer recognize them as an authorized user of their laptop (or may not authenticate them at all if they have been removed from the directory).

In this way, Active Directory assists system administrators by solving the final task of applying specific policies / authorizations to distributed resources for security / compliance purposes, which makes it a great choice for a directory service in any companies that own Windows-based technical resources.

> **Note**: By utilizing a more advanced feature of Windows called [**Group Policy**](https://www.howtogeek.com/125171/htg-explains-what-group-policy-is-and-how-you-can-use-it/), system administrators can also **remotely install or upgrade software** (i.e. Microsoft Office, Outlook, etc.) onto groups of domain-joined hosts.
>
> However, this document is focused on Active Directory as it pertains to Rancher users / developers (who would use **Kubernetes** as a container orchestrator to schedule such software onto hosts), so it won't discuss this further.

## Integrating Active Directory with Internal Applications

The same idea leveraged by Windows computers (laptops or servers) to authenticate users via Active Directory can be extended to applications that connect to Active Directory through a protocol known as **LDAP**.

### Why would applications want to use Active Directory?

An application like [Rancher](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/authentication-permissions-and-global-configuration/authentication-config/configure-active-directory) is a great example here.

Rancher can use LDAP to establish a session that allows it to **authenticate** users via Active Directory when they log into Rancher. 

This approach has two distinct advantages:

1. **Offloads the responsibility of storing users and authenticating them**: this simplifies the application's responsibilities as a piece of software since there's no need to maintain user tables in some sort of database or support the management of users, which has strong security implications

> **Note**: Since Rancher (as an internal application) supports other authentication protocols as well, including local authentication via a user store within the local / management cluster it runs on, this point does not necessarily apply to Rancher. But for most internal applications that do not need to support completely different organizations using it, this point will apply.

2. **Centralizes the management of users to Active Directory**: Without this integration, a system administrator would need to ensure that a user who is added / removed from Active Directory is also added / removed from **each** of the internal applications like Rancher that are owned by the company, which would be a nightmare!

> **Note**: It's important to identify that integrating with Active Directory works best for a class of applications that provide services that are **internal** to an organization.
>
> While there may be specific cases that merit it, you probably shouldn't be using something like ActiveDirectory for external account management.
>
> i.e. Applications that support **private** accounts, like Rancher or a content management system like Wordpress, are good examples of those who can / should consider integrating with Active Directory.
>
> i.e. Applications that support **public** accounts, like Reddit or Twitter, that need to support the dynamic registration of users or have a possibly infinite pool of potential users that may not benefit from being organized into groups may want to consider alternatives.

#### Example: An Internal Rate Limiting Service

To give a different / more complex example, think of an internal application designed by a development team that manages default [rate limits](https://www.cloudflare.com/learning/bots/what-is-rate-limiting/) imposed on external users who are hitting a public endpoint offered by the development team.

If this internal application would allow developers on the team to increase or decrease default rate limits imposed on public users, you would ideally want this internal application to force internal users to log in and authenticate themselves before they can increase or decrease any rate limits.

> **Note**: Why do internal users need to authenticate themselves? 
>
> You wouldn't want a user who left a company who still has access to that internal application's endpoint in some other way to be able to arbitrarily increase or decrease rate limits.
>
> This could allow a malicious internal user that has left the organization to [DoS](https://en.wikipedia.org/wiki/Denial-of-service_attack) the public endpoint by removing certain rate limits from certain accounts.
>
> While you may consider the fact that it's unlikely that a user who has left the company still has access to an internal application's endpoint (if it is hidden behind a VPN, for example), it's still important from an information security perspective to secure an internal endpoint to achieve [defense in depth](https://en.wikipedia.org/wiki/Defense_in_depth_(computing)).

Therefore, for the same reasons as listed above (especially the second point), you'd want to integrate with Active Directory **on an application layer** to offload the responsibility of authenticating and managing users over to Active Directory.

### How do applications connect to and query Active Directory?

[LDAP (lightweight directory access protocol)](https://www.okta.com/identity-101/what-is-ldap/) is the **protocol** that is used by an application to connect to **any** directory service and query it, including something like Active Directory.

It's analagous to how HTTP(s) is used as the standard for most modern applications to communicate with each other but remains **vendor-agnostic**.

Therefore, it's expected that **any** application that uses LDAP and can authenticate itself against the LDAP-compliant service (known as an **LDAP server**) can use it to query information about other users in that directory.

### How do applications authenticate users via LDAP?

When an application seeks to authenticate a user using LDAP, they need to first collect two pieces of information:

1. The **distinguished name** that uniquely represents the user's location within the directory service

2. The **password** that can be used to authenticate the user

Since the distiguished name is not often known to the user directly (and may change over time if the user moves around the same organization), the application will usually go through a process known as **DN resolution** to resolve the distinguished name of a user from some other piece of information that identifies the user, such as the user's **username** or **email**.

This is done by the application running a **search** on the LDAP server to try to find the user based on the provided information.

> **Note**: Imagine DN resolution as the equivalent of the application running a SQL query on a user database, where the user database is the LDAP server and the query is an [`ldapsearch` query](https://devconnected.com/how-to-search-ldap-using-ldapsearch-examples/).
>
> Obviously, to run the query in the first place the application needs to be **connected to / authenticated by** the database, which means that the application itself needs some sort of identity to authenticate itself against the LDAP server.
>
> This is where **Service Accounts** come into the picture, which represent an identity the application can assume to authenticate itself to an LDAP server.
>
> This will be discussed in more detail in the next section.

Once the distinguished name is identified, the process of the application passing on these credentials to the LDAP server to run an authentication request is known as **binding**.

The LDAP server will respond to this request with a success or failure response, after which the application has successfully authenticated the user.

### Providing Identities to Internal Applications (gMSAs)

As discussed in the above section, internal applications can utilize LDAP to offload the responsibility of authenticating users to Active Directory.

However, to query Active Directory, the internal application itself needs to be **an authorized user on Active Directory**.

This can happen in two ways:
1. (BAD) An authorized user can run the internal application using their own credentials. Since they are part of their own domain, the internal application can use their credentials to authenticate against Active Directory to run user queries. However, from a security perspective, this approach would not follow the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege). In addition, from a functionality perspective, this approach would break if that user were to be removed from the organization, since all applications running under their user would no longer be authorized to talk to Active Directory.
2. (GOOD) An internal application can be run using a [service account](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-service-accounts), which is not tied to any users.

While Microsoft previously supported the second approach by introducing Managed Service Accounts (MSAs), Microsoft's new and recommended approach is to utilize [**Group Managed Service Accounts (gMSAs)**](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview), which can be created by system administrators just like they create and manage users / groups and given specific authorizations that are scoped to the task they need to perform (i.e. allow the application to perform the LDAP bind command to authenticate a user).

> **Note**: The primary difference between MSAs and gMSAs is that MSAs cannot be shared across computers.
>
> This makes it a bad candidate for the identity of applications that can be scheduled on any number of servers (via an **orchestrator**, like Kubernetes).

As long as an authorized user starts the service that is configured to use a gMSA (or the service receives the gMSA's ephemeral credentials that can be rotated on demand or on a schedule by a system administrator), the application is no longer reliant on the user who started it and will only have the permissions granted by gMSA.

### The big picture

While it's possible that a reader may have perfectly understood how this whole authentication process works by reading the above sections, other readers may find it hard to keep track of all the identities involved in setting up an internal application from the above section.

So here is a summary of the overall process:

1. A **system administrator** authenticates themselves with Active Directory using their own credentials. They **manually** deploy the internal application using their credentials using a command that instructs the Windows host to use a particular gMSA for this application.

2. On deployment, the **internal application** is allowed to assume the roles of a particular gMSA, which enables it to run LDAP search and LDAP bind commands. Once it is up and running, it offers up an endpoint for unauthenticated users to login through.

3. On attempting to authenticate themselves, a **user** provides their username and password to the application. The application uses its own credentials to **authenticate** itself as an **authorized user** on the LDAP server, which establishes a connection that the application can use to execute an LDAP search. This search identifies the distinguished name of the user from the provided username. The application then passes the user's distinguished name and password through the same connection to issue an LDAP bind request that authenticates the user.

The important part to take away from the above summary is that there is a [**chain of trust**](https://en.wikipedia.org/wiki/Chain_of_trust) established through this process, which is what **authorizes** the internal application to execute authentication requests.

Namely:
- The application is **authorized** since it is provided credentials to **authenticate** as the gMSA
- The application can **authenticate** as the gMSA since a system administrator **authorizes** the application to use that gMSA
- The system administrator is **authorized** to create applications that assume gMSAs, so they simply need to **authenticate** themselves (by logging in) and execute the command to launch the application.

Therefore, Active Directory implicitly trusts the application to perform authentication requests because its trust is rooted in the fact that an **authenticated, authorized user launched the application**.

While the remaining steps will be the same, the only difference that will come about as a result of **containerizing an application** (the topic of the next section) will be the first step, since the role of the system administrator who **manually** starts the application will be automated.

## Containerizing Windows applications that use Active Directory

As described in deeper detail in the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/gmsa-run-container), it's possible to configure a containerized Windows application to utilize gMSA credentials.

This involves two steps:

1. Providing the container with credentials that it can use to authenticate against Active Directory so that Active Directory will **allow** the application to assume the roles identified by the credential spec

2. Configuring the container on start with security options that identify a [**credential spec**](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#create-a-credential-spec), which tells the computer which gMSA(s) the container should be able to assume
 
> **Note**: This exactly matches what the system administrator does to manually deploy applications that use Active Directory!
>
> The first step is equivalent to the system administrator **logging in**.
>
> The second step is equivalent to the system adminstrator identifying the gMSA that needs to be used as part of the command they use to deploy the application.

### What is a Credential Spec?

The credential spec is a file containing a JSON document that looks something like this:

```json
{
    "CmsPlugins": [
        "ActiveDirectory"
    ],
    "DomainJoinConfig": {
        "Sid": "S-1-5-21-702590844-1001920913-2680819671",
        "MachineAccountName": "webapp01",
        "Guid": "56d9b66c-d746-4f87-bd26-26760cfdca2e",
        "DnsTreeName": "contoso.com",
        "DnsName": "contoso.com",
        "NetBiosName": "CONTOSO"
    },
    "ActiveDirectoryConfig": {
        "GroupManagedServiceAccounts": [
            {
                "Name": "webapp01",
                "Scope": "contoso.com"
            },
            {
                "Name": "webapp01",
                "Scope": "CONTOSO"
            }
        ]
    }
}
```

There are a couple of important pieces of information that this credential spec provides:

1. `DomainJoinConfig.DnsName` / `DomainJoinConfig.NetBiosName`: the server that hosts the Active Directory to reach out to
2. `DomainJoinConfig.MachineAccountName`: the **default** gMSA account that this application will assume the role of
3.  `ActiveDirectoryConfig.GroupManagedServiceAccounts[*].Name`: **all** gMSA accounts that any processes within the container can assume

> **Note**: We won't cover the meaning behind `ActiveDirectoryConfig.GroupManagedServiceAccounts[*].Scope` in this document since utilizing multiple gMSAs across multiple ActiveDirectory instances in one container is an advanced feature, as it requires a trust to also be established between the computer's domain and the gMSA's domain.
>
> However, it can generally be assumed for basic use cases that the scope for every account should always be the Active Directory Domain's DNS root (`contoso.com`) and the Active Directory Domain's NetBIOS name (`CONTOSO`).

### Authenticating with Active Directory to use a gMSA

While the credential spec identifies which gMSA this application will assume **after** it has already been authenticated with Active Directory, the container needs to have credentials to authenticate with Active Directory in the first place.

These credentials are **not** contained in the credential spec for security reasons; instead, they are passed in one of two ways.

#### Using the `NetworkService` Account (on building the container)

The old approach of authenticating the container to assume a gMSA involved actually modifying the container image on build to set the user to the [`NetworkService` account](https://learn.microsoft.com/en-us/windows/win32/services/networkservice-account), a predefined local account that presents **host credentials** on authenticating against remote servers (like Active Directory).

As a result, if the host itself is part of the Active Directory domain, all containers running on it that utilize the `NetworkService` account will also authenticate against the same domain **using host's identity / credentials**, after which it can assume the appropriate gMSA identified by the credential spec.

> **Note**: This is akin to a domain-joined computer itself taking on the role of a system administrator to deploy the application that assumes a gMSA.
>
> Since computers can be joined to only one domain, a fundamental limitation of this approach is that only workloads tied to the domain that the host is joined to can be scheduled on this host.
>
> Deploying workloads that need access to different Active Directory domains on the same host cannot be supported.

#### Using Container Credential Guard (on runtime)

This is the new approach that involves a far more complex setup process, but the general idea here is identified in the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#gmsa-architecture-and-improvements) and involves the use of `ccg.exe` (Container Credential Guard) and a specialized CCG Plugin that is installed on all Windows hosts as a [DLL (Dynamic Link Library)](https://learn.microsoft.com/en-us/troubleshoot/windows-client/deployment/dynamic-link-library).

In short, the CCG-based solution for passing in Active Directory credentials generally follows this process:

1. You add some account credentials from Active Directory domain(s) into a "secret store", i.e. any place where a secret can be securely stored, like [Azure KeyVault](https://github.com/microsoft/Azure-Key-Vault-Plugin-gMSA).

2. A specially-designed gMSA CCG **plugin** that can talk to your secret store is installed onto the Windows host as a [DLL (Dynamic Link Library)](https://learn.microsoft.com/en-us/troubleshoot/windows-client/deployment/dynamic-link-library)

3. Your credential spec is updated to provide CCG information on the plugin's GUID (a unique identifier for the DLL on the system) and the CLI arguments to be passed when invoking the plugin

4. On running a container, CCG contacts your plugin, which retrieves credentials from your secret store, which allows the container to authenticate, which allows it to assume the gMSA that is also identified from your credential spec.

> **Note**: Why would Microsoft recommend this more complicated approach for deploying containers utilizing gMSAs?
>
> This primarily matters when you're in a scenario where you are utilizing a **container orchestrator** (i.e. Kubernetes) and have **multiple domains**.
>
> This extremely common for enterprises with multiple teams (i.e. multiple domains) who would like to deploy their internal applications within a Kubernetes cluster with Windows nodes.
>
> To give a specific example, imagine that you have two containerized applications being deployed that need to adopt gMSA account within their own domain.
>
> If you were to use the `NetworkService` account, you would need to have **two** Windows nodes; one joined to each domain. Then you would need to carefully orchestrate those workloads (likely using nodeSelectors) onto the specific node that is connected to the right domain.
>
> If you wanted to scale up, you would simiarly need to maintain **two Windows node pools**, which increases your costs.
>
> However, in the CCG approach, since all nodes that have the same CCG plugin installed that responds differently based on the input provided within the credential spec (which can be configured to pass back a different set of credentials based on the desired domain), containers can be scheduled onto **every** Windows node, regardless of whether the Windows node is domain joined since host credentials are no longer used.
>
> Therefore, both containerized applications can actually run on the same Windows node, despite the fact that they are authenticating against different domains.

#### Example: Azure Key Vault CCG Plugin

To give a concrete example of a CCG Plugin that can be used in Azure environments, let's break down Microsoft's [Azure Key Vault Plugin (CCGAKV Plugin)](https://github.com/microsoft/Azure-Key-Vault-Plugin-gMSA), which was built to be used for [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes).

In CCGAKV, the "secret store" is [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/basic-concepts), which can be accessed from Azure VMs using [Azure Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview).

As described in the [Microsoft docs](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-managed-identities-work-vm#system-assigned-managed-identity), a VM (whose identity has been granted permissions to access the key vault) can reach out to the [Azure Instance Metadata Service (IMDS)](https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=windows) at `http://169.254.169.254/metadata/identity/oauth2/token`, which will return an access token that can be used to make a call to Azure Key Vault to retrieve credentials.

To describe the process in more detail:

1. A **system administrator** creates one or more gMSAs in Active Directory, adds them to a single group, and creates an single user account (which we'll call the **impersonation account**) that has permissions to assume the role of any member of the gMSA group.

2. A **system administrator** copies the credentials of the impersonation account into Azure Key Vault (in the format `domain\user:password`).

3. A **system administrator** takes some Azure CLI steps to ensure that the all Windows hosts have the CCGAKV Plugin DLL installed, all Windows hosts are allowed to access the Key Vault (by creating an identity for both the VMs and Azure Key Vault and running a command to grant access), and each gMSA has a `CredentialSpec` added to the cluster that allows a workload to acquire its credentials.

> **Note**: On installing the plugin DLL, the plugin should exist at `C:\Windows\System32\CCGAKVPlugin.dll`, registered under the GUID `CCC2A336-D7F3-4818-A213-272B7924213E`.

> **Note**: At this point in the process, unless specific steps were taken by the system administrator to set up the managed identities such that specific groups of Windows hosts can be identified by label (so that workloads requiring gMSAs from a specific domain can be specifically targeted on them) and only limited permissions were provided to each host, it's likely that all hosts will have permissions to access all domain credentials.
>
> If this is the case, any user who can log onto any host would be able to query the Instance Metadata Service from the host, grab the access token, and use it to grab credentials of any domain account that host has access to.
>
> This point will be relevant when we describe the Rancher implementation of a CCG Plugin.

4. On creating a container, **CCG** invokes the installed CCGAKV DLL with argument provided from the credential spec.

5. The **CCGAKV DLL** uses uses the access token from the Azure IMDS to access the Active Directory credentials from Azure Key Vault and returns a response back to CCG.

6. **CCG** uses the response to inject the gMSA(s)'s username and password into the container

7. The **container** uses the injected credentials to assume the role of the gMSA(s) added to the container, which enables it to run LDAP search and LDAP bind commands. Once it is up and running, it offers up an endpoint for unauthenticated users to login through.

8. On attempting to authenticate themselves, a **user** provides their username and password to the application. The application uses the gMSA credentials to connect to the LDAP server and executes an LDAP search on that connection, which identifies the distinguished name of the user. The application then passes the user's distinguished name and password through the same connection to issue an LDAP bind request that authenticates the user.

Just like before, we can identify the chain of trust by following the sequence backwards:

- The application is **authorized** since it is provided credentials to **authenticate** as the gMSA

- The application can **authenticate** as the gMSA since CCG injects the gMSA credentials into the container

- CCG can acquire the gMSA credentials since it is **authorized** to invoke the DLL to get impersonation account credentials, which it can use to **authenticate** itself with Active Directory to retrieve the gMSA credentials that the impersonation account is **authorized** to retrieve.

- The DLL can acquire the credentials needed to pass onto CCG since it can retrieve credentials from Azure IMDS, which allows it to **authenticate** with the host's managed identity using an access token that represents an identity that is **authorized** to retrieve credentials from Azure Key Vault (due to the established trust set up by the system administrator during the third step).

Therefore, Active Directory implicitly trusts the application to perform authentication requests because its trust is rooted in the fact that:

1. CCG must be the only host process that invokes the CCG Plugin DLL (and only does so to create valid containers that require gMSA credentials).

2. The CCGAKV DLL must be the only host process that attempts to acquire an access token from the Azure IMDS to authenticate against Azure Key Vault to retrieve credentials.

## Active Directory / gMSAs in Kubernetes

Now that we have established:
1. **Why you would want to use gMSAs in applications**: to offload authentication and management of users to ActiveDirectory, primarily for a class of internal applications authenticating users who are part of an organization
2. **How gMSA can be used in containerized applications**: by providing credentials (host or via CCG) to authenticate against Active Directory and a credential spec that says what gMSA this application should assume

The next section will contextualize this content for deploying Windows containers leveraging gMSAs in Kubernetes.

### Why use gMSAs in Kubernetes?

You want to deploy your internal, containerized applications across multiple Windows machines for **scalability and fault-tolerance**, in case one of the machines goes down or you experience increased load.

### How do you deploy Windows workloads requiring gMSA onto Kubernetes?

First, a user needs to perform the **one-time actions** performed by a system administrator in each domain identified in the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#gmsa-architecture-and-improvements), incldying:
1. Generating a KDS key on your Active Directory setup to allow it to use gMSAs
2. Creating gMSAs and impersonation accounts in Active Directory

Once you have performed those basic steps, it is recommended for users to install [the GMSA webhook chart](https://github.com/kubernetes-sigs/windows-gmsa/tree/master/charts) maintained by [SIG Windows](https://github.com/kubernetes/community/blob/master/sig-windows/README.md).

> **Note**: The Rancher Windows team also maintains a copy of this chart that is available on Rancher's Apps & Marketplace.

Here, instead of creating the credential spec as a file directly on the host, you would pass in the same details to a `GMSACredentialSpec` CR whose CRD is installed onto the cluster on installing the webhook.

> **Note**: The `GMSACredentialSpec` is a **global** resource, which means that it is not tied down to any specific namespace.

This will ensure that all workloads that pass in `spec.template.spec.securityContext.windowsOptions.gmsaCredentialSpecName` will utilize that GMSA Credential Spec.

Once that's done, you'll need to follow the steps to install a CCG Plugin onto your cluster (such as the CCGAKV solution described above) so that each node that needs to schedule gMSA workloads can get the credentials it needs.

To do this, any Kubernetes cluster can utilize Rancher's CCG Plugin (CCGRKC) solution.

### Rancher Kubernetes Cluster CCG Plugin (CCGRKC)

As a fully Kubernetes-native solution, the Rancher Kubernetes Cluster CCG Plugin (CCGRKC) treats the Kubernetes cluster it runs on as the "secret store" where Active Directory credentials for impersonation accounts are held.

As a result, there is **no strict dependency** on any external key storage service like Azure Key Vault and it can be used regardless of the underlying infrastructure provider used to provision hosts.

To install Rancher's CCG Cluster Plugin, **system administrators / cluster owners** just need to install following Helm charts onto a **secure / locked-down** namespace:

1. `rancher-ccg-dll-installer`: a Helm chart that creates a `DaemonSet` to install the CCGRKC DLL onto all Windows hosts. This should only be installed **once**.
2. `rancher-gmsa-account-provider`: a Helm chart that creates a `DaemonSet` that hosts an HTTPs server (known as the **Account Provider**) on each Windows host that it can be scheduled on (configurable via `nodeSelectors`). This should be installed **once per impersonation account** that you would like nodes in the cluster to be able to access.

Once installed, a system administrator should place the credentials of the impersonation account in the release namespace and whose name matches the format `<rancher-gmsa-account-provider-release-name>-creds`.

The chart will also automatically create `CredentialSpec` CRs based on the values supplied to the chart, so once you're done adding the credentials you can start scheduling Windows workloads utilizing gMSA credentials!

#### Why do I need to install one Helm chart per impersonation account?

There are a couple of reasons why you must create a **separate** release of the `rancher-gmsa-account-provider` Helm chart onto the same namespace for **each** impersonation account you add to your cluster.

From a security perspective, this encourages a system of **least privilege** since system administrators are offered a security control over which nodes get access to Active Directory credentials in the form of **nodeSelectors** applied on the `rancher-gmsa-account-provider` workload.

> **Note**: To elaborate, since the `DaemonSet` deployed by each `rancher-gmsa-account-provider` release will only be authorized to read a specific Secret in the release namespace named `<rancher-gmsa-account-provider-release-name>-creds`, a user who has permissions to exec into a Windows host, exec into the `rancher-gmsa-account-provider` container, and make a request to the Kubernetes cluster by impersonating the container's service account credentials can only access the Active Directory credentials that container has access to until the container is descheduled from the host (and cannot access credentials that were never scheduled on the host in the first place).

From a system administrator's perspective, deploying one Helm release per impersonation account also makes sense since adding a gMSA to a cluster would require one of two things:

1. **If an impersonation account that can assume the role of the new gMSA has already been added to a cluster**: run a `helm upgrade` to add a new gMSA to the `values.yaml` of the Helm release, which will create a `CredentialSpec` that can be used by Windows workloads

2. **Otherwise**: run a `helm install` to add the impersonation account to the cluster, specifying all gMSAs that it can assume the role of in the `values.yaml` of the Helm release so that it can automatically create a `CredentialSpec` per gMSA.

#### Security Model

To understand the security model, we can draw a parallel between the way that the CCGRKC plugin works and the way the CCGAKV plugin works.

While the CCGAKV plugin invokes the Azure IMDS by accessing a defined endpoint (`http://169.254.169.254/metadata/identity/oauth2/token`), the CCGRKC plugin references **a set of files mounted on the host** by the `rancher-gmsa-account-provider` Pod that identify:

1. The **host port** that the `rancher-gmsa-account-provider` HTTPs server is listening on
2. The **client and server certificates** that can be used to establish an [mTLS](https://en.wikipedia.org/wiki/Mutual_authentication) connection with it

Therefore, the set of files mounted on the host in the CCGRKC implementation effectively represents the Azure IMDS in the CCGAKV implementation since both provide the **connection details used to talk to their respective "secret store"**.

On invocation, a call is made from the DLL to the `rancher-gmsa-account-provider` HTTPs server, which can use its `ServiceAccount` credentials to **authenticate** itself to the Kubernetes API Server and retrieve the contents of the Kubernetes secret that contains the impersonation account's credentials (which it will be **authorized** to do via a `RoleBinding` attached to its `ServiceAccount`).

Therefore, the HTTPs server in the CCGRKC implementation effectively represents Azure Key Vault in the CCGAKV implementation since both are **providers of the stored credentials** that you can authenticate against using previously retrieved credentials.

Therefore, in CCGRKC, Active Directory implicitly trusts the application to perform authentication requests because its trust is rooted in the fact that:

1. CCG must be the only host process that invokes the CCG Plugin DLL (and only does so to create valid containers that require gMSA credentials).

2. The CCGAKV DLL must be the only host process that **has access to the set of files mounted on the host** to authenticate against **the HTTPs server that is authenticated and authorized to query the Secret in the Kubernetes cluster** to retrieve credentials.