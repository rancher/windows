# What are domain controllers?

Domain controllers (DCs) are the heart of Active Directory.

On a high level, each domain controller serves the following roles in a domain:

1. **Distributed Database**: Maintains a **global catalog** of all organizational data and **replicates** that database across other domain controllers to avoid a single point of failure
2. **Distributed API Server**: Implements APIs (described [here](./storing_and_querying_data.md#api-layer)) and maintains **schemas** that contain definitions of objects stored in Active Directory and the attributes of those objects
3. **DNS Server**: Provides **DNS services** that automatically provide **every** object stored on a domain controller a DNS name (prefixed by the DC's DNS name). This allows Windows computers on the same network to discover domain controllers and other technical resources on the network via Active Directory DNS

> **Note** Every Active Directory domain has a DNS domain name (i.e. `ad.com`),
>
> The domain controller is also assigned a DNS name (i.e. `dc-1.ad.com`) and every resource tracked by an Active Directory domain will have a DNS name (i.e. `server1.ad.com`).
>
> Domains are also assigned a [NetBIOS](https://en.wikipedia.org/wiki/NetBIOS) name, which is an identifier that is at most 15 characters.

Every domain always has one **Primary Domain Controller (PDC)** that will contain the master directory database.

Other domain controllers added to the domain will take the role of **Backup Domain Controllers (BDCs)**; the PDC replicates its data to the BDCs on a regular interval.

## Special Domain Controllers

Two special types of domain controllers operate at a **global** scale.

### Global Catalog

The **Global Catalog** domain controller stores all the data across all domains in an entire forest. If there is more than one forest, it will also store a subset of data from each of the other forests.

The first domain controller added to a forest takes on this role by default but more than one domain controller can assume this role.

When users perform a search on Active Directory, they first contact one of these Global Catalog domain controllers, which reduces the need to query each domain's domain controller separately.

### Operations Masters

**Operations Master** domain controllers maintain consistency across the entire database.

The following five sub-roles are each focused on maintaining consistency with a particular aspect of the database.

1. **Schema**: Responsible for handling schema changes across the entire forest
2. **Domain Naming**: Responsible for handling domain CRUD across the entire forest
3. **Relative Identifier (RID)**: Allocates blocks of RIDs to each domain controller in a domain. Whenever a domain controller creates a new security principal, such as a user, group, or computer object, it assigns the object a **unique security identifier (SID)**. This **SID** consists of a domain **SID**, which is the same for all security principals created in the domain, and a **RID**, which uniquely identifies each security principal created in the domain.
4. **Primary Domain Controller (PDC) Emulator**: The PDC emulator receives preferential replication of password changes performed by other domain controllers in the domain. It provides the latest password information whenever a logon attempt fails as a result of a bad password. Services like Group Policy and Distributed File System prefer to reach out to the PDC first. For this reason, of all operations master roles, the PDC emulator operations master role has the highest impact on the performance of the domain controller that hosts that role. The PDC emulator in the forest root domain is also the default Windows Time service (W32time) time source for the forest.
5. **Infrastructure**: Responsible for updating object references in its domain that point to an object in another domain. This server updates object references locally and uses replication to bring all other replicas of the domain up to date. The object reference contains the object’s globally unique identifier (GUID), distinguished name and possibly a SID. The distinguished name and SID on the object reference are periodically updated to reflect changes made to the actual object. These changes include moves within and between domains as well as the deletion of the object. If the infrastructure master is unavailable, the domain blocks updates to object references until it comes back online.

## Resources

To read more about Active Directory Domain Controllers, please read the [Microsoft docs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc786438(v=ws.10)).
