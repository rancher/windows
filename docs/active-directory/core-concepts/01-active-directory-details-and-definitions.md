# Active Directory Details and Definitions 

### Active Directory Domain Services

Active Directory Domain Services (AD DS, or more simply just AD for Active Directory) is a storage and management
mechanism for everything related to a collection of resources within a computer network. This includes users, files,
network configurations, and devices like physical computers and printers. Administrators can modify the Active Directory
and remotely manage all the components currently tracked at once. In its simplest terms, AD is used to logically
represent an organizations resources and users and enforce policies and behaviors across them.

AD Includes the following features

- Data schemas which enforce particular requirements onto AD data
- A global catalog of data
- Query and Indexing mechanisms for finding and publishing data
- Database replication to BDCs

### AD Storage Structure

[From MS Docs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc759186(v=ws.10))

“*Administrators use **Active Directory** to store and organize objects on a network (such as users, computers,
devices, and so on) into a secure hierarchical containment structure that is known as the **logical structure**.
Although the **logical structure** of **Active Directory** is a hierarchical organization of all users, computers,
and other physical resources, the **forest** and **domain** form the basis of the logical structure. **Forests**,
which are the **security boundaries of the logical structure**, can be structured to provide data and service autonomy
and isolation in an organization in ways that can both reflect site and group identities and remove dependencies on the
physical topology.”*

![OU Stands for ‘Organizational Unit’](../media/Untitled.png)


[From MS Docs](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2003/cc780036(v=ws.10)#structure-and-storage-technologies)

*“**AD DS** uses **domains** and **forests** to represent the **logical structure** of the directory hierarchy.
**Domains** are used to manage the various populations of users, computers, and network resources in your enterprise.
The **forest represents the security boundary for AD DS**. Within Domains, you can create **organizational units** to
subdivide the various divisions of administration.*

*The **logical structure** of AD DS includes a two-dimensional definition that can be viewed as a hierarchy, even though
the objects themselves are stored in a flat database file. In addition to its own name, each object stores the name of
the container directly above it in the hierarchy. That container object stores the name of its superior container,
and so on, up to the root container. In this way, a logical structure is imposed that can be viewed by using AD DS tools
as a tree of containers. By virtue of a hierarchical naming system, the objects in the tree appear to be nested inside
(contained by) other objects.”*

The main components of the Active Directory logical structure are described as follows

- Active Directory Forest
    - The highest level in the hierarchy. A forest represents a self-contained directory. It is a security boundary, 
    which gives administrators have complete control and access to all the information inside both the Forest and all
    Domains within the Forest.
- Domain
    - Domains partition the information that is stored inside the directory into smaller portions so that the
  information can be more easily stored on various domain controllers and so that administrators have a greater
  degree of control over replication. Data that is stored in the directory is replicated throughout the forest from
  one domain controller to another. Some data that is relevant to the entire forest is replicated to all domain
  controllers. Other data that is relevant only to a specific domain is replicated only to domain controllers in
  that particular domain. A good domain design makes it possible to implement an efficient replication topology.
  This is important because it enables administrators to manage the flow of data across the network, that is, to
  control how much data is replicated and where that replication traffic takes place.
- Organizational Unit (OU)
    - OU’s provide a way to group resources so that they can be managed as a single unit. This allows admins to apply
group policies across many computers or control access of resources for many users. OUs can also be delegated to 
specific admins, so that they only have control over their subset of resources.

Other core components of an Active Directory are

- DNS Support
    - DNS is used to locate Domain Controllers, as well as used during the Domain naming process. All domains are 
     organized in a root and subordinate domain hierarchy.
    - Every Active Directory domain has a DNS domain name (for example, [cohovineyard.com](http://cohovineyard.com/)),
      and every domain joined computer has a DNS name (for example, 
      [server1.cohovineyard.com](http://server1.cohovineyard.com/)). Architecturally, domains and computers are
      represented both as objects in Active Directory and as nodes in DNS.
- Active Directory Schema
    - The schema contains definitions of objects which can store information in the Active Directory. It provides the 
      attributes associated with particular resources.
    - Different Windows versions will have different schema versions, when different versions of windows are used to 
      comprise the Active Directory server they will agree upon a shared Schema.
- The Data store
    - A data store comprises three components. The first being a collection of interfaces used to communicate with the
      store, the second being the underlying services and logic which perform CRUD on the store, and the third is the
      literal data. Each data store is represented as a single file replicated across all domain controllers.
    - Proper logical structuring of an Active Directory will ensure that Domain Controllers will only have access to the
      data required for their domain, keeping replication quick and simple. Improper structuring can saturate the
      network with replication data.

### The Components and Interfaces of Active Directory Storage

There are several storage components that come together to form the data handling of a DC

The core interfaces used to communicate with the storage layer are

- LDAP, Lightweight Directory Access Protocol
- Replication within the domain controller management interface
- A Messaging API
- A Security Accounts Manager (SAM)

The core components of the storage layer are

- Directory System Agent (DSA)
- The Database, typically represented as a single file replicated across all Domain Controllers
- Extensible Storage Engine (ESE)

![Data Store Architecture](../media/Untitled%201.png)
