# Using Active Directory For Internal Applications

Internal applications can leverage Active Directory to authenticate **internal** users and get authorizations stored in Active Directory.

## Why would internal applications want to integrate with Active Directory?

### Single endpoint for all authentication and authorization requests

Without Active Directory, each internal application would need to independently have a secure way of storing user credentials, keeping track of user attributes / authorizations, and querying the user store to perform authentication / authorization requests (such as logging into the application).

Offloading the responsibility of authenticating users and providing authorizations to Active Directory vastly simplifies the logic each internal application needs to support user logins.

### Centralize the management of users in an organization

If each internal application were to have their own user store, a system administrator would need to ensure that an internal user added / removed from Active Directory is also added / removed from **each** of the internal applications owned by the company.

By ensuring that all internal applications always reach out to Active Directory to authenticate users, Active Directory becomes the source of truth for all organizational data.
