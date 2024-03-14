# What is LDAP?

[LDAP (lightweight directory access protocol)](https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol) is the **protocol** that an application can use to connect to an **LDAP Server** (i.e. Active Directory) and query information about other users in that directory.

It's analogous to how HTTP(s) is the standard for most modern applications to communicate with each other but remains **vendor-agnostic**.

## How do applications authenticate via LDAP?

### Establish an LDAP Session

The first step any application takes when communicating with an LDAP server is establishing an **LDAP session**.

This is primarily done by sending an LDAP request to TCP/UDP port `389` (or `636` for LDAP over TLS/SSL, known as LDAPS).

After establishing the session, the session starts off as an **anonymous** session. Typically, LDAP servers should not allow any other operations in an anonymous session till a `BIND` occurs.

### Authenticating the LDAP Session (`BIND`)

To establish an authenticated session, the application needs to issue a **`BIND`** request (a process referred to as **binding**) by sending a user's credentials over the established session.

These credentials include:

- A **user identifier** (i.e. a username or email)
- The user's **password**

> **Note**: Depending on the application, the credentials sent in the `BIND` request may authenticate the **application's identity** itself (i.e. a [gMSA](../active_directory/gmsa/README.md) or another form of credentials tied to the application).
>
> This is common practice in applications that need to perform LDAP operations like adding, deleting, or modifying an entry or searching for other users and groups (i.e. requests like "who else is on the same team as the person with these credentials?") where the user's credentials themselves do not have those permissions.

The LDAP server will respond to this request with a success or failure response, after which the application has authenticated the LDAP session.

> **Note**: Since an **unencrypted** LDAP session transmits these credentials by default, it's important to use [Transport Layer Security (TLS)](https://en.wikipedia.org/wiki/Transport_Layer_Security) when establishing the LDAP session in the first place.
>
> This is why you would want to use LDAPS.

### Distinguished Name (DN) Resolution (`SEARCH`)

A common use case for contacting an LDAP server is to resolve a user's **distinguished name (DN)**, a string that uniquely represents the user's location within the directory service, and other attributes tied to that user.

Since the distinguished name is not known to the user directly (and may change over time if the user moves around the same organization), **DN resolution** is a process where an application runs a `SEARCH` request through an authenticated LDAP session to resolve the distinguished name of a user from some other piece of information that identifies the user, such as the user's **username** or **email**.

> **Note**: DN resolution is like an application running a SQL query on a user database, where the user database is the LDAP server and the query is an [`ldapsearch` query](https://devconnected.com/how-to-search-ldap-using-ldapsearch-examples/).

Once the application can identify the distinguished name, the application now can access more attributes about the user on the LDAP server.
