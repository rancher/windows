# gMSA Overview and Details

[From MS Docs](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview#BKMK_APP)

*“gMSAs provide a single identity solution for services running on a server farm, or on systems behind Network Load 
Balancer. By providing a gMSA solution, services can be configured for the new gMSA principal and the password 
management is handled by Windows.”*

gMSA’a (Group Managed Service Account) and sMSA’s (Standalone Managed Service Account) are identity management 
solutions offered within Active Directory. They provide secure login for various Windows services, such as MS SQL and 
provide automated password management. Automated password management means that passwords can be more complex and 
therefore more secure, as no human is expected to remember the string. Additionally, a gMSA can be shared across many 
computers in a server farm (This is where the **Group** part of gMSA's comes into play) which allows for load 
balancing as all instances will share the same credentials, and this is the distinct benefit of using gMSA’s over
sMSA’s.

In general, gMSA’s work best with native windows applications and services, including features such as MS SQL or
administrative host level automation. It is also possible for third party applications to integrate with gMSA accounts.

gMSA authenticates users using the Microsoft Key Distribution Service (KDS) in conjunction with a Domain Controller.
The KDS will distribute a key that will be used by the Domain Controller to compute a password, and hosts will reach
out to the Domain Controller to retrieve the password. KDS will periodically change the key used to compute the
password, resulting in a new password. Hosts will be able to contact the Domain Controller to get both the current and
preceding password. This password is never stored on a domain controller, and is computed each time it is needed. 
The password is then used to generate a Kerberos ticket for use with other services.
([Source](https://learn.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview#BKMK_SOFT))

### Kerberos Authentication

[From MS Docs](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview):

“**Kerberos is an authentication protocol that is used to verify the identity of a user or host … The Kerberos Key
Distribution Center (KDC) is integrated with other Windows Server security services that run on the domain controller.
The KDC uses the domain's Active Directory Domain Services database as its security account database.”**

KDS uses Kerberos encryption types when creating the gMSA password and Ticket Ticket-Granting Ticket (TGT).
The Ticket-Granting Ticket is used as a user access token to request access tokens for other services.
Once a ticket has been granted, a process does not need to know the gMSA password to perform its actions.
More information on TGT’s can be found here: [Source](https://learn.microsoft.com/en-us/windows/win32/secauthn/ticket-granting-tickets).

The particular encryption method used is expected to be understood by both KDS and the Domain Controller. 
At minimum, AES must be supported. All KDS instances need to use the same encryption type, which will allow any
instance to compute the same password for a given duration. KDS will generate a root key used to generate all gMSA
account passwords. This root key is an extremely privileged resource which is critical to securing the gMSA accounts,
and one root key is expected to be used for all gMSA accounts

### gMSA Networking

The reliance on the Domain Controller means that any host which wants to utilize a gMSA must be joined to a particular
domain within the active directory so that it may contact a Domain Controller. This seems obvious, however this
requirement has implications for auto-scaling hosts as it introduces a significant amount of over-head on a per-host
basis as each one will need to join the domain.

Due to the main benefit of gMSA’s being that they can be used across a number of hosts, they are the go-to service
account for clustered solutions, including Kubernetes. 
