# gMSA Outside the Domain

Accessing gMSA credentials from hosts outside the domain is becoming increasingly important due to
the overhead required to join a domain and the prevalence of cluster computing. This desired functionality was the
impetus for the creation of the Container Credential Guard (`ccg.exe`) application and associated plugins. Ensuring 
that such behavior is possible requires an understanding of both the `ccg.exe` program and the plugins it consumes, 
as well as the architectural decisions on how to enable outside access to Domain Controllers. 

### Architectural Requirements

In order for non-domain joined hosts to access gMSA credentials, they must be able to contact a Domain Controller.
When designing a Kubernetes solution, the actual infrastructure comprising the nodes of the cluster are, more often than
not, in a separate network or datacenter from the Active Directory infrastructure. A means of communication must be
established between the two, and the means in which this is done should be assessed on a case-by-case basis. 

### CCG.exe: Windows Container Credential Guard Server

`ccg.exe` is an executable included on Windows operating systems, introduced in Windows 2019.
As its name implies, it is responsible for handling credentials for containerized applications. It plays a critical role
in the gMSA authentication process. The chain of operations when using the `ccg.exe` server is as follows
([Source](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#gmsa-architecture-and-improvements))

1. `ccg.exe` is started by passing a Credential Spec file to the executable
2. `ccg.exe` uses the information in the Credential Spec file to launch a plugin for a particular storage provider
    (AKV, Kubernetes Secret, etc.) which then retrieves the credentials required to contact a Domain Controller.
    The desired plugin is specified within the Credential Spec file via a GUID. The input provided to the plugin is also
    stored in the Credential Spec file, under the `PluginInput` key. 
3. `ccg.exe` uses that retrieved credentials to get the gMSA password from Active Directory
4. The container authenticates with Active Directory using the gMSA password and gets a
   Kerberos Ticket-Granting Ticket (TGT)
5. Applications can now use the Kerberos ticket and related metadata to interact with the Active Directory
6. Any work which requires a gMSA account can now be performed

![Diagram describing `ccg.exe`'s role in the gMSA authentication process for non-domain joined nodes ](../media/Untitled%202.png)

Diagram describing `ccg.exe`'s role in the gMSA authentication process for non-domain joined nodes 

So, *plugins* are specific to a particular storage mechanism while `ccg.exe` facilitates the intermediary communication
with Active Directory so that the gMSA password can be passed to the container and exchanged for a TGT.

---

> [Continue to the next page](06-gmsa-ccg-plugin.md) to learn more about how the Windows OS provides support for containerized gMSA's in non-domain-joined nodes 