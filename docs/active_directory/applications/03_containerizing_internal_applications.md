# Containerizing Internal Applications

> **Note**: From here on out, these docs will focus on how to containerize **Windows** applications that use [Integrated Windows Authentication (IWA)](https://learn.microsoft.com/en-us/aspnet/web-api/overview/security/integrated-windows-authentication) to authenticate under their own application identity (i.e. a [gMSA](../gmsa.md)).

Configuring a containerized Windows application to use gMSA credentials involves two steps:

1. Configuring the container on start with security options that identify a [**`CredentialSpec`**](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#create-a-credential-spec), which is a JSON document that describes how the runtime should identify this application and which gMSA the application will use.

2. Providing the **container runtime** with credentials that it can use to authenticate against Active Directory so that Active Directory will **allow** the container runtime to create an application container that assumes the gMSA defined in the `CredentialSpec`.

> **Note**: In this case, the **container runtime** is taking the role of the system administrator who manually identifies the application's gMSA (now located in the `CredentialSpec`) and starts the application based on their credentials (which is now done by the container runtime, using the provided credentials).

## What is a Credential Spec?

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

You can create a gMSA for `GMSA01` by running a command using [this PowerShell module](https://www.powershellgallery.com/packages/CredentialSpec/1.0.0):

```powershell
New-CredentialSpec -AccountName GMSA01 -Path "C:\MyFolder\my_gmsa_creds.json"
```

There are a couple of important pieces of information that this credential spec provides:

1. `DomainJoinConfig.DnsName` / `DomainJoinConfig.NetBiosName`: the server that hosts the Active Directory to reach out to
2. `DomainJoinConfig.MachineAccountName`: the **default** gMSA account that this application will assume the role of
3. `ActiveDirectoryConfig.GroupManagedServiceAccounts[*].Name`: **all** gMSA accounts that any processes within the container can assume

> **Note**: We won't cover the meaning behind `ActiveDirectoryConfig.GroupManagedServiceAccounts[*].Scope` in this document since utilizing gMSAs across Active Directory instances in one container is an advanced feature.
>
> For basic use cases, the scope for every account should be the Active Directory Domain's DNS root (`contoso.com`) and the Active Directory Domain's NetBIOS name (`CONTOSO`).

## Authenticating with Active Directory to use a gMSA

> **Note**: This section talks about how acquiring the gMSA's **password**.
>
> To find out how the gMSA's password is actually used to perform an authentication request, please see the [gMSA docs](../gmsa.md).

While the credential spec identifies which gMSA this application will assume **after** it authenticates with Active Directory, the container needs to have credentials to authenticate with Active Directory in the first place.

These credentials are **not** contained in the credential spec for security reasons; instead, the runtime acquires them in one of two ways/

### Using the `NetworkService` Account (on building the container)

The old approach of authenticating the container to assume a gMSA involved actually modifying the container image on build to set the user to the [`NetworkService` account](https://learn.microsoft.com/en-us/windows/win32/services/networkservice-account), a predefined local account that presents **host credentials** on authenticating against remote servers (like Active Directory).

As a result, if the host itself is part of the Active Directory domain, all containers running on it that use the `NetworkService` account will also authenticate against the same domain **using host's identity / credentials**, after which it can assume the appropriate gMSA identified by the credential spec.

> **Note**: This is akin to a domain-joined computer itself taking on the role of a system administrator to deploy the application that assumes a gMSA.
>
> Since computers can belong to one domain, a fundamental limitation of this approach is the workloads scheduled on the computer must be in the same domain.
>
> Deploying workloads that need access to different Active Directory domains on the same host is not possible.

### Using Container Credential Guard (on runtime)

This is the new approach that involves a far more complex setup process, but the general idea here (described in the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#gmsa-architecture-and-improvements)) involves the use of `ccg.exe` (Container Credential Guard) and a specialized CCG Plugin installed on all Windows hosts as a [DLL (Dynamic Link Library)](https://learn.microsoft.com/en-us/troubleshoot/windows-client/deployment/dynamic-link-library).

In short, the CCG-based solution for passing in Active Directory credentials generally follows this process:

1. You add some account credentials from Active Directory domain(s) into a "secret store", i.e. any place where a secret can be securely stored, like [Azure KeyVault](https://github.com/microsoft/Azure-Key-Vault-Plugin-gMSA).

2. You install a [DLL (Dynamic Link Library)](https://learn.microsoft.com/en-us/troubleshoot/windows-client/deployment/dynamic-link-library) onto your host that provides a method to talk to your secret store.

3. Your credential spec provides `ccg.exe` information on the plugin's GUID (a unique identifier for the DLL on the system) and CLI arguments that invoke the plugin DLL.

4. On running a container, `ccg.exe` contacts your plugin, which retrieves credentials from your secret store, which allows the container to authenticate, which allows it to assume the gMSA that is also identified from your credential spec.

> **Note**: Why would Microsoft recommend this more complicated approach for deploying containers utilizing gMSAs?
>
> This primarily matters when you're in a scenario where you are utilizing a **container orchestrator** (i.e. Kubernetes) and have **more than one domain**.
>
> This is common for enterprises with more than one team (i.e. more than one domains) who would like to deploy their internal applications within a Kubernetes cluster with Windows nodes.
>
> To give a specific example, imagine that you have two containerized applications deployed that need to assume a gMSA account within their own domain.
>
> If you were to use the `NetworkService` account, you would need to have **two** Windows nodes; one joined to each domain. Then you would need to orchestrate those workloads (i.e. using nodeSelectors) onto the specific node connected to the right domain.
>
> If you wanted to scale up, you would similarly need to maintain **two Windows node pools**, which increases your costs.
>
> In the CCG approach, since all nodes that have the same CCG plugin installed that responds differently based on the input provided within the credential spec (i.e. the same plugin can pass back a different set of credentials based on the desired domain based on provided arguments), **every** Windows node can schedule the containers, regardless of whether the Windows node is domain joined since host credentials are no longer used.
>
> Both containerized applications can actually run on the same Windows node, despite the fact that they are authenticating against different domains.

### Example: Azure Key Vault CCG Plugin

To give a concrete example of a CCG Plugin, let's break down Microsoft's [Azure Key Vault Plugin (CCGAKV Plugin)](https://github.com/microsoft/Azure-Key-Vault-Plugin-gMSA), which [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes) clusters use.

In CCGAKV, the "secret store" is [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/basic-concepts), Azure VMs can access using [Azure Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview).

As described in the [Microsoft docs](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-managed-identities-work-vm#system-assigned-managed-identity), a VM (whose identity has permissions to access the key vault) can reach out to the [Azure Instance Metadata Service (IMDS)](https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=windows) at `http://169.254.169.254/metadata/identity/oauth2/token`, which will return an access token that can make a call to Azure Key Vault to retrieve credentials.

To describe the process in more detail:

1. A **system administrator** creates one or more gMSAs in Active Directory, adds them to a single group, and creates a single user account (which we'll call the **impersonation account**) that has permissions to assume the role of any member of the gMSA group.

2. A **system administrator** copies the credentials of the impersonation account into Azure Key Vault (in the format `domain\user:password`).

3. A **system administrator** takes some Azure CLI steps to ensure that the all Windows hosts have the CCGAKV Plugin DLL installed, all Windows hosts can access the Key Vault (by creating an identity for both the VMs and Azure Key Vault and running a command to grant access), and each gMSA has a `CredentialSpec` added to the cluster.

4. On creating a container that uses `CredentialSpec`, **`ccg.exe`** invokes the installed CCGAKV DLL at `C:\Windows\System32\CCGAKVPlugin.dll` with argument provided from the credential spec (i.e. the CLSID `CCC2A336-D7F3-4818-A213-272B7924213E`).

5. The **CCGAKV DLL** uses the access token from the Azure IMDS to access the Active Directory credentials from Azure Key Vault and returns a response back to `ccg.exe`.

6. **`ccg.exe`** uses the response to inject credentials into the container.

7. The **container** uses the injected credentials to assume the role of the gMSA(s) added to the container. Once it starts, it can perform operations such as querying Active Directory.

### Chain Of Trust (CCGAKV)

Like before, we can identify the chain of trust by following the sequence backwards:

- The application is **authorized** since it provides credentials to **authenticate** as the gMSA

- The application can **authenticate** as the gMSA since `ccg.exe` injects the gMSA credentials into the container

- `ccg.exe` gets the gMSA credentials since `ccg.exe` is **authorized** to invoke the DLL to get impersonation account credentials, which `ccg.exe` can use to **authenticate** itself with Active Directory to retrieve the gMSA credentials that the impersonation account is **authorized** to retrieve.

- The DLL gets the credentials needed to pass onto `ccg.exe` since it can retrieve credentials from Azure IMDS, which allows it to **authenticate** with the host's managed identity using an access token that represents an identity that is **authorized** to retrieve credentials from Azure Key Vault (due to the established trust set up by the system administrator during the third step).

Active Directory implicitly trusts the application to perform authentication requests because it believes:

1. No host process except `ccg.exe` invokes the CCG Plugin DLL (and `ccg.exe` creates valid, user-requested containers that require gMSA credentials).

2. No host process except those that invoke the CCGAKV DLL acquires an access token from the Azure IMDS to authenticate against Azure Key Vault to retrieve credentials.

## Resources

To read more about how containerizing Windows application to use gMSAs works, please read the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/gmsa-run-container).

To read more about how to run a Windows container with gMSA on a non-domain joined host, please read [this useful blog post](https://www.fearofoblivion.com/running-a-windows-container-under-gmsa).

To read more about non-domain-joined credential specs, please read the [Microsoft docs](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts).
