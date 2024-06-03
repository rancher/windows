# Storing and Querying Data

Each domain controller (DC) has four layers when it comes to storing and querying data:

## API Layer

This is the layer that other computers on the network (domain controllers or domain-joined computers) primarily interact with, which consists of four primary components:

1. **[Lightweight Directory Access Protocol (LDAP)](./ldap.md)**: An application protocol used to share information about users, systems, networks, services, and applications that exist across a network; this is commonly used by internal applications who are trying to query Active Directory to authenticate users with a given set of credentials.
2. **Replication (REPL)**: APIs used by other domain controllers to trigger the replication of data
3. **Messaging API (MAPI)**: APIs used to communicate with [Microsoft Exchange Server](https://en.wikipedia.org/wiki/Microsoft_Exchange_Server) to make applications become email-aware.
4. **Security Accounts Manager (SAM)**: APIs that deal with local user and group accounts stored in a special database file in the Windows registry.

## [Directory System Agent](https://learn.microsoft.com/en-us/windows/win32/ad/directory-system-agent)

The [Directory System Agent](https://learn.microsoft.com/en-us/windows/win32/ad/directory-system-agent) is the set of services and processes that provide access to the data store on a domain controller.

This daemon executes LDAP and MAPI requests to provide information from the data store and triggers calls to the REPL APIs on other domain controllers to perform data replication and keep the data store up-to-date.

## Database Layer (`ntds.dit`)

`ntds.dit` (found in `C:\Windows\NTDS` by default) is the single database file on each domain controller that physically stores all the Active Directory objects for a single forest.

This is the file that the Directory System Agent primarily interacts with.

## Extensible Storage Engine (ESE)

The Extensible Storage Engine (ESE) is the underlying data storage technology used to store and update information in the Active Directory database file.

ESE ensures that every change to the database is a single unit called a **transaction**, which contains the changed data and metadata such as the object's GUID, timestamp, version, and other information.

When the Directory System Agent make a write request by invoking `esent.dll`, the following steps occur:

1. ESE writes the transaction to a transaction buffer in memory
2. ESE records the transaction in `Edb.log`
3. ESE records an uncommitted transaction in `Edb.chk`
4. ESE performs the transaction on `ntds.dit`
5. ESE records a committed transaction in `Edb.chk`

This way, if a failure occurs while partially writing data, Active Directory can check `Edb.chk` to see which transactions are pending.
