# Data Replication

## What is data replication?

**Data replication** is a process that happens when Active Directory domain controllers need to synchronize to ensure that the querying the database produces **consistent** results.

When a domain controller receives changes, they are automatically replicated to other domain controllers in a systematic fashion.

## What happens during replication?

On receiving updates, each domain controller will update the database file called `ntds.dit` (found in `C:\Windows\NTDS` by default).

This single database file is where Active Directory physically stores all Active Directory objects for a single forest.

## How do different domain controllers engage in data replication?

By default, Active Directory automatically designs a connection topology between domain controllers for replicating data.

This default connection topology **maximizes directory consistency** and **minimizes the impact to network traffic** by making optimal use of physical network connections.

## Why is it important to consider data replication?

When designing Active Directory (i.e. defining forests, domains, and organizational units) for your organization, you should consider **the amount of replication data** and **where that replication traffic takes place**.

For example, since one database file (`ntds.dit`) stores all the information for a domain and that database file requires constant replication across all domain controllers for a domain, it may be more efficient to split users across different domains as that will reduce or split up the amount of replication traffic in your datacenter.

## Resources

To read more about Active Directory internals, please read the [Microsoft docs](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/replication/active-directory-replication-concepts).
