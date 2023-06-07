# Related Resources

- Active Directory
    - [https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
    - [https://en.wikipedia.org/wiki/Active_Directory](https://en.wikipedia.org/wiki/Active_Directory)
- Active Directory Domains:
    - [https://en.wikipedia.org/wiki/Active_Directory](https://en.wikipedia.org/wiki/Active_Directory)
    - Specifics on Domain Controller types: [https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc786438(v=ws.10)](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc786438(v=ws.10))
- A incredibly useful blog post regarding the use of a gMSA plugin (One of very few resources describing this functionality)
    - [https://www.fearofoblivion.com/running-a-windows-container-under-gmsa](https://www.fearofoblivion.com/running-a-windows-container-under-gmsa)
- example repositories containing a .NET application which implements the gMSA credential plugin
    - [https://github.com/ChrisKlug/FiftyNine.CCG.KeyVault](https://github.com/ChrisKlug/FiftyNine.CCG.KeyVault) and https://github.com/macsux/gmsa-ccg-plugin
- General docs on gMSA
    - [https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview)
- Microsoft Documentation on the GMSA credential spec format for both joined and non-joined hosts
    - [https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#additional-credential-spec-configuration-for-non-domain-joined-container-host-use-case](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts#additional-credential-spec-configuration-for-non-domain-joined-container-host-use-case)
- upstream web-hook repository
    - https://github.com/kubernetes-sigs/windows-gmsa
- COM introduction
    - [https://mohamed-fakroud.gitbook.io/red-teamings-dojo/windows-internals/playing-around-com-objects-part-1](https://mohamed-fakroud.gitbook.io/red-teamings-dojo/windows-internals/playing-around-com-objects-part-1)