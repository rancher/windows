# gMSA In Docker / Containterd

gMSA’s can be used in a number of contexts, one example context could be an application which needs to interact with
an MS SQL server to perform some sort of continuous maintenance or analysis. This application is not associated with a
real person, and it may be beneficial to have many instances of it running at any one point.

Applications such as this have been around long before the introduction of containerization technology, using
information stored on the host directly to handle authorization for gMSA accounts. However, eventually this program
needs to be containerized, so it can be more easily managed and scaled. This is where an issue arises wherein the
virtualized environment of the container can no longer directly access the required Active Directory information stored
on the host which is needed to get the gMSA password and TGT.

To solve this issue, many container runtimes such as docker and containerd have provided flags which allow a user to
pass a file (generally referred to as a ‘gMSA credential Spec’) to the container which can then be used within the
program. The credential spec is a set of metadata which can be used to connect to a Domain Controller. When passing the
metadata manually, the credential spec file for the gMSA must be manually created using PowerShell and stored as a file.
This file can then be passed as a security option to the container at runtime.

The following command can be used as a reference to create a new credential spec file, assuming a gMSA account has been
created and the host executing this command is executed on is domain joined.

```powershell
New-CredentialSpec -AccountName WebApp01 -Path "C:\MyFolder\my_gmsa_creds.json"
```

Running a container manually with a gMSA credential spec file would look like the following

```bash
docker run -it --security-opt "credentialspec=file://www.json" microsoft/windowsservercore cmd
```

The credential spec file `www.json` in the above example would have the following structure

```json
{
"CmsPlugins": [
        "ActiveDirectory"
    ],
    "DomainJoinConfig": {
        "Sid": "S-1-5-21-2554468230-2647958158-2204241789",
        "MachineAccountName": "gmsaecs",
        "Guid": "8665abd4-e947-4dd0-9a51-f8254943c90b",
        "DnsTreeName": "example.com",
        "DnsName": "example.com",
        "NetBiosName": "example"
    },
    "ActiveDirectoryConfig": {
        "GroupManagedServiceAccounts": [
            {
                "Name": "gmsaecs",
                "Scope": "example.com"
            }
        ]
    }
}
```

The host would then use this information to contact a Domain controller and retrieve the gMSA password. This security
option is for use exclusively with windows images, as gMSA’s are an Active Directory concept not shared with Linux.
This approach requires that the host be domain joined so metadata stored on the host may be used during the Domain
Controller connection process. 

---
> [Continue to the next page](04-gmsa-in-kubernetes.md) to learn more about how gMSA's are supported within Kubernetes 