# Terminology

## Objects

**Objects** are the core building block of Active Directory's logical representation of an organization. Every object belongs to a single domain.

An object can be a:

- [User](#domain-user-accounts)
- File
- Network Configuration
- Device (physical computer, printer)

Administrators can use Active Directory to remotely manage all the tracked components all at once by using grouping mechanisms (i.e. organizational units, domains, forests) to **enforce policies and behaviors** across them.

### Domain User Accounts

**Domain user accounts** are objects that authenticate users within an Active Directory domain.

Each account has **credentials** that allow you to sign in as that user into any domain-joined computer.

### Service Accounts / Group Managed Service Accounts

**Service accounts / Group Managed Service Accounts** are objects that track accounts tied to applications that can authenticate against Active Directory.

For more details, check out the [gMSA docs](./gmsa/README.md).

### Domain-Joined Computers

**Domain-joined computers** are Windows computers that have joined an Active Directory domain.

On logging in, these Windows computers are automatically configured to reach out to Active Directory with the provided credentials to authenticate that these credentials belong to a valid domain user account.

If an administrator removes a domain user account, that account will no longer be able to log into any domain-joined computer.

### Group Policies

[**Group Policy**](https://www.howtogeek.com/125171/htg-explains-what-group-policy-is-and-how-you-can-use-it/) are objects that can specify policies that apply to other objects in a domain, such as:

1. Limitations to network capabilities (changing networks)
2. Maps between local directories to networked directories
3. Maps between networked printers and computers
4. Policies that prevent users from using the command prompt or similar administrative tools
5. Desktop level configurations, such as the customizing the start menu

Group Policy can also specify what software should exist on a domain-joined computer (i.e. Microsoft Office, Outlook, etc.), which would trigger **remotely installing or upgrading software** on those computers.

## Organizational Units

An **organizational unit (OU)** is the simplest way of grouping objects within a given domain in Active Directory.

OUs can represent soft boundaries, such as different teams in the same organization.

> **Note**: Every organizational unit belongs to a single domain.

## Domains

A **domain** in Active Directory is a directory that contains one or more Active Directory objects and/or organizational units.

Domains represent users, groups, or technical resources who are all associated with the same organization.

One or more **domain controllers (DCs)** (i.e. specialized servers maintained by a system administrator that runs Active Directory Domain Services for a given domain / forest) store all the information associated with a single domain.

DCs belonging to a domain replicate domain-level data to all other domain controllers that manage the same domain (and some global DCs).

## Forests

A **forest** in Active Directory contains one or more domains (and their domain controllers).

DCs with the `Global` role replicate forest-level data across all domain controllers in the forest (across all domains).

### Why would system administrators want to set up a forest?

Even though there is an overhead with having more than one domain (namely, more domain controllers), there are two primary reasons why system administrators may want to set up a forest:

1. **Security**: splitting information across forests creates a **hard security boundary** since different sets of domain controllers store and manage information for a domain. Different system administrators can also manage different domains.
2. **Database Replication**: Since fault tolerance requires all domain controllers tied to a given domain to replicate their database across other domain controllers, splitting Active Directory across different sets of domain controllers helps administrators manage the flow of data across the network, that is, to control how much data needs replication and where that replication traffic takes place.
