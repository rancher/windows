# The gMSA CCG Plugin

The gMSA CCG plugin is a COM+ application which can be used to gather authorization details for a Domain Controller from
a non-domain joined host by accessing Azure Key Vault or some other object store containing the credentials. The core
logic within the plugin is very direct, after registration with the windows host the plugin `dll` will provide a
function to retrieve credentials from a data store as needed. It then transforms the response into a format expected by
`ccg.exe` which then uses it to retrieve the gMSA password. 

Plugins must be installed on each host which is capable of running a windows container utilizing a gMSA. Many plugins
may be installed at a time, and Microsoft recommends keeping a 1 to 1 relation between a plugin and a storage mechanism,
i.e. discrete plugins for AKV, Kubernetes Secrets, AWS Secrets Manager, etc. 

To power the plugin, the same gMSA credential spec content as seen in previous examples is enhanced with a new field
consumed by the plugin. Microsoft recommends that a standard format be used when naming the credentials in an object
store so that the credential spec can concisely specify the credential name. An example of a gMSA credential spec for a
non-domain joined host looks like the following 

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
        ],
        "HostAccountConfig": { <-- New!
            "PortableCcgVersion": "1", <-- this should always be '1'
            "PluginGUID": "{GDMA0342-266A-4D1P-831J-20990E82944F}", <-- must equal GUID inside the plugin source code
            "PluginInput": "contoso.com:gmsaccg:<password>" 
        }
    }
}
```

### gMSA CCG Plugin, Azure Key Vault, and General Object Stores

The CCG plugin is responsible for providing the Domain Controller password to `ccg.exe`. `ccg.exe` will then
authenticate with a Domain Controller using the retrieved Domain password, and retrieves the gMSA password. The gMSA
password is then passed back to the container, which then requests a new Kerberos Ticket-Granting Ticket (TGT) from the
Domain Controller. The TGT is then used by the container to interact with other domain services.

Currently, it seems many existing solutions use Azure Key Vault as the service for storing the Domain credentials.
However, the actual object store is arbitrary as long as it can be securely accessed. In its simplest form, a remote
object store is not needed and the credentials can just be provided within the Credential Spec JSON / CR - though this
approach still requires a plugin to exist for extracting that data. 

Microsoft recommends deciding on a standard naming convention for whatever object store is being used. One such
convention can be seen in the Credential Spec’s `Plugin Input` section, 

```powershell
"PluginInput": "Domain.Name:Domain.User:Domain.User.Password"
e.g. 
"PluginInput": "contoso.com:gmsaccg:<password>" 
```

A plugin provider may define any format useful to the plugin. The above format is simple and would provide the login
credentials directly without a remote store. This approach introduces security concerns as the credential would be
exposed on Kubernetes resources, and it would still require a dedicated plugin.

In cases where the domain username and password are stored in a remote object store, the format would be specific to
that object store and provide the means of authenticating with it from within the plugin. One example of such a format
could be the following,

```powershell
"PluginInput": "StoreProvider=<SOME OBJECT STORE>;StoreName=<OBJECT STORE NAME>;clientId=<CLIENT ID>;SecretName=<SECRET NAME>"
```

Such a format would allow a user to define what remote object store should be queried, what directory within that store
will contain the credential, and any authorization information needed to access that credential. 

This format should be well-thought-out as it will contain sensitive information and should be standardized once the
plugin has been released. There are pros and cons to having dedicated input formats for particular object stores, or
having a generalized format for all stores.

### COM+

COM+ is an evolution of Microsoft's Component Object Model, which provides a means of interprocess communication.
The protocol was initially developed to facilitate communication between Microsoft products, such a MS Word and MS Excel
communicating the state of an embedded spreadsheet. The technology has since improved and become more simplified
allowing it to be used in a number of other contexts. 

While COM applications can technically be developed in any language, and was primarily created for C++, The .NET
framework can create COM+ applications natively in C#. This is a more modern approach to developing the plugin and 
automates a lot of the nitty-gritty when creating a COM+ application.  

COM applications are identified using a GUID (A.K.A a UUID) which must stay the same. Microsoft states that *‘Plug-ins
are unique to the secret store used to protect the portable user account credentials. For example, different plug-ins
would be needed to store account credentials in Azure Key Value vs a Kubernetes secret store’.*  

When the plugin is queried by `ccg.exe` during a gMSA credential authorization operation, this is done via COM.