# What is Active Directory?

Active Directory (otherwise known as Active Directory Domain Services, or ADDS) is a **directory service** built by Microsoft.

> **Note**: A directory service is one that stores a **catalog** of all resources (namely, user accounts, groups, and technical resources like computers or printers) owned by a single organization grouped / organized in a directory structure (i.e. like the files and folders on a computer).
>
> In other words, it's a **storage and management mechanism** for everything related to a collection of resources within a computer network.

**System administrators** (i.e. IT professionals, as opposed to application developers) generally manage Active Directory.

## Why use Active Directory (or any directory service)?

Imagine that you are a system administrator at a new company who needs to set up their IT department.

You would probably start by:

1. Come up with an organizational chart of all individuals who are part of this company and where they fall under the company hierarchy

2. Distribute technical resources (i.e. laptops, printer access, etc.) to these individuals or entities and use a system to keep track of those resources

3. Identify how you can apply specific **policies / authorizations** to the distributed resources for security / compliance purposes (i.e. give most users the lowest possible privileges on provided laptops, but assign the application development team admin privileges over their laptops)

Once you do this, you'll also need to make sure that **rolling maintenance work** is manageable (i.e. keeping track of resources when individuals leave a company, get promoted / demoted, change roles, etc.).

## Using any directory service

Any directory service helps solve the first two tasks.

It allows you to define your organizational chart and keep track of technical resources by:

1. Adding or removing individuals in your organization as **users** within a directory

2. Defining roles (like application developer) as **groups** within a directory that users or other groups can belong to

3. Adding technical resources (also known as network resources) within a directory

4. Creating independent directories that can contain users, groups, technical resources, or other directories to represent organizational structures (i.e. Finance v.s. Engineering)

## Using Active Directory

As a directory service, Active Directory's specific advantage is its built-in support for allowing system administrators to manage the permissions / authorizations on **Windows computers**.

**Domain joining** is the term that describes the process of adding a Windows computer to Active Directory.

> **Note**: Every resource (i.e. user, group, computer, etc.) tracked by a system administrator in Active Directory belongs to one **domain**.
>
> When adding a computer to a domain, the computer authenticates with a **domain controller (DC)** using the credentials of a user (i.e. system administrator) who has permissions to do so.

Once a computer is domain-joined, the computer itself can authenticate against the domain controller to perform other actions.

For example, it can send a request to check if a set of credentials are valid, which user it corresponds to, and what authorizations that user should have (i.e. does the user have permission to log in? Should they have admin privileges? etc.).

> **Note**: The [security controls](https://en.wikipedia.org/wiki/Security_controls) offered to system administrators for domain-joined Windows machines are granular.
>
> For example, you can even control authorizations like "allow access to certain sections of the Windows control panel" or "make sure every computer's main page is this URL".

## Managing Organizational Changes

In a domain-joined host, since the computer reaches out to Active Directory to authenticate users every time, **rolling changes applied by system administrators to the organization are automatically applied to all technical resources tracked by Active Directory**.

For example, if a system administrator changes the permissions of the user on Active Directory, they will no longer be able to log into their laptop since the laptop will reach out to Active Directory for authentication, which may no longer recognize them as an authorized user of their laptop (or may not authenticate them at all if removed from the directory).

Administrators can also apply [Group Policies](./terminology.md#group-policies) to apply other specific policies / authorizations to distributed resources for security / compliance purposes, which makes it a great choice for a directory service in any companies that own Windows-based technical resources.
