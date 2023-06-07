# Active Directory Domains, Data, Accounts, and Controllers

*From Wikipedia and the [Microsoft Docs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc759550(v=ws.10)#active-directory-and-dns-domain-names)*

“*A **Windows domain** is a form of a [computer network](https://en.wikipedia.org/wiki/Computer_network) in which all
[user accounts](https://en.wikipedia.org/wiki/User_account), computers, printers and other
[security principals](https://en.wikipedia.org/wiki/Principal_(computer_security)), are registered with a central
database located on one or more clusters of central computers known as
[domain controllers](https://en.wikipedia.org/wiki/Domain_controller_(Windows)). Authentication takes place on domain
controllers. Each person who uses computers within a domain receives a unique user account that can then be assigned
access to resources within the domain. Starting with [Windows Server 2000](https://en.wikipedia.org/wiki/Windows_Server_2000),
[Active Directory](https://en.wikipedia.org/wiki/Active_Directory) is the Windows component in charge of maintaining
that central database.[[1]](https://en.wikipedia.org/wiki/Windows_domain#cite_note-ADinW2K-1) The concept of a Windows
domain is in contrast with that of a [workgroup](https://en.wikipedia.org/wiki/Workgroup_(computer_networking))
in which each computer maintains its own database of security principals.*”

Domains represent, as well as partition, the logical structure of an Active Directory. This is done both to reduce the
amount of resources any one admin may have control over, and ensures that data replication is done in an efficient
manner. Data specific to a particular domain is replicated only to the DCs for that Domain. Some Domain Controller can
be given a Global Role, at which point they will replicate data across all Domains in a Forest. Additional roles exist
to ensure data consistency within a Domain. Proper design of Domains within the Forests which comprise an Active
Directory is an important part of creating a proper Active Directory network.

A Domain is not a physical object, rather it is an administrative unit. A Domain is similar to, but independent of,
a Work Group. Each domain is used as a node within the Active Directory DNS network (along with individual computers),
and domains may have subdomains in a similar fashion to more typical web domains.

Along with a DNS name, Active Directory Domains are also assigned a `NETBIOS` name, which is a legacy means of
identifying a resource. It should be known that a `NETBIOS` name is limited to at most 15 characters,
so while in ideal situations it is expected to be equal to the DNS prefix there are cases where it is only
a subset of that prefix.

## Active Directory Domain Controllers

Active Directory Domain Controllers represent the main API server responsible for handling operations occurring with
a particular Domain. There may be one or many Controllers per domain, and Controllers may have special roles assigned
to them to achieve different outcomes within a Forest.

There are two main types of domain controllers

1. Single Primary Domain Controller (PDC)
    1. A single computer responsible for controlling the domain. It contains a master directory database which includes
       all the Domains resources and security information
2. Backup Domain Controllers (BDC)
    1. Backups for the Primary Domain Controller. These can also be used in conjunction to the Primary Domain
       Controller as a load balancing solution. The databases are automatically replicated across all BDC from the
       PDC on a periodic basis.

Domain Controllers can be assigned a dedicate type to better handle data replication and consistency 
([Source](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc779716(v=ws.10)))

1. Standard
    1. A standard Domain Controller is responsible for storing one domain directory partition, as well as the schema
       and configuration settings for the forest the domain is located within.
2. Global Catalog
    1. A Global Catalog Domain Controller will store data from all domains across the entire forest. The controller
       will also store a subset of information from all other domains in all other forests. This is the first controller
       to be contacted when a search is initiated within the Active directory, and this role prevents the need to query
       multiple controllers to find what you need. The first domain controller in a forest is automatically given a
       Global Catalog role, but more can be added as needed.
3. Operations Masters
    1. These types are responsible for maintaining consistency across the entire database. There are five sub-roles, each
       focusing on maintaining consistency with a particular aspect of the database. All operations related to a
       particular role will be routed only to a controller with that role. This ensures conflicts and duplicate
       records are avoided.
        1. Schema Master
            1. Responsible for handling schema changes across the entire forest
        2. Domain Naming Master
            1. Responsible for handling domain CRUD across the entire forest
        3. Relative ID Master
            1. The **relative identifier (RID) operations master** allocates blocks of RIDs to each domain controller
               in the domain. Whenever a domain controller creates a new security principal, such as a user, group,
               or computer object, it assigns the object a unique security identifier (SID). This SID consists of a
               domain SID, which is the same for all security principals created in the domain, and a RID, which
               uniquely identifies each security principal created in the domain.
        4. Primary Domain Controller Emulator
            1. **The primary domain controller (PDC) emulator operations master**. The PDC emulator receives
                 preferential replication of password changes that are performed by other domain controllers in the
                 domain, and it is the source for the latest password information whenever a logon attempt fails as
                 a result of a bad password. It is a preferred point of administration for services (examples are Group
                 Policy and Distributed File System, DFS). For this reason, of all operations master roles, 
                 the PDC emulator operations master role has the highest impact on the performance of the domain
                 controller that hosts that role. The PDC emulator in the forest root domain is also the default
                 Windows Time service (W32time) time source for the forest.
        5. Infrastructure Master
            1. The **infrastructure operations master** is responsible for updating object references in its domain
               that point to the object in another domain. The infrastructure master updates object references locally
               and uses replication to bring all other replicas of the domain up to date. The object reference contains
               the object’s globally unique identifier (GUID), distinguished name and possibly a SID. The distinguished
               name and SID on the object reference are periodically updated to reflect changes made to the actual
               object. These changes include moves within and between domains as well as the deletion of the object.
               If the infrastructure master is unavailable, updates to object references are delayed until it comes
               back online.

### Domain Data Management

[From MS Docs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc780036(v=ws.10)#structure-and-storage-technologies):

*“AD DS uses objects to store and reference data in the directory. 
The AD DS database file (**Ntds.dit**) provides the physical storage of all AD DS objects for a single forest. 
Although there is a single directory, some directory data is stored within domains while other data is distributed 
throughout the forest, without regard for domain boundaries. Beginning with Windows Server 2003, data can also be 
distributed to domain controllers according to applications that use the data, where the scope of distribution can be 
set according to the needs of the application”*

[From MS Docs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc780036(v=ws.10)#replication-technologies):

*“Objects in the directory are distributed among the **domain controllers** in a forest, and all domain controllers 
can be updated directly. AD DS replication is the process by which the changes that are made on one domain controller 
are automatically synchronized with other domain controllers. Data integrity is maintained by tracking changes on each 
domain controller and updating other domain controllers in a systematic way. By default, AD DS replication uses a 
connection topology that is created automatically. This replication topology makes optimal use of physical network 
connections and frees administrators from having to determine which domain controllers replicate with one another. 
The replication topology can also be created manually. AD DS replication is designed to maximize directory consistency 
and minimize the impact to network traffic.”*

### Domain user Accounts

When using Domains, user accounts are not tied to a particular computer. Instead, all user accounts are stored in the 
**Active Directory**, which exists in the **Domain Controllers**. This allows you to sign onto any computer in the 
Domain and access the same data, and provides a means for Administrators to disable or create users across all 
computers. Domains may contain both user accounts and service accounts, as well as a plethora of other resources.

### Domain Control and Administrative Advantages

Domains allow for scalable control of computers using the **Active Directory** system as well as **Group Policy**. 
**Group Policies** allow admins to limit network capabilities (changing networks), map local directories to networked 
directories, prevent users from using the command prompt or similar administrative tools, map networked printers to 
particular computers, as well as other desktop level configurations such as the start menu. 
