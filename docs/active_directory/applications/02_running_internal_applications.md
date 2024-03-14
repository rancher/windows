# Running Internal Applications

## Before running the application

To run an internal application that uses Active Directory, a system administrator must figure out:

1. **Runtime**: What component runs this application and keeps it up?
2. **Identity**: What identity should the internal application use to run?
3. **Authentication Protocol**: Which authentication protocol should you use to have your application communicate with Active Directory?

Typically, the solution used for the first problem varies depending on the environment you are running the application within.

For example, you can run the application as a [Windows Service Application](https://learn.microsoft.com/en-us/dotnet/framework/windows-services/introduction-to-windows-service-applications) or use a container orchestrator like [Kubernetes](https://kubernetes.io/).

> **Note**: The next two sections will talk about containerizing and running these applications in Kubernetes.

For the second problem, the application's identity needs to be something that Active Directory recognizes.

The most common solution is to use a **[Group Managed Service Account (gMSA)](../gmsa/README.md)**.

For the third problem, applications can leverage one of the following two authentication protocols:

1. **[Lightweight Directory Access Protocol (LDAP)](../ldap.md)**: an application protocol that allows internal applications to present credentials to establish a connection with Active Directory
2. **[Integrated Windows Authentication (IWA)](https://learn.microsoft.com/en-us/aspnet/web-api/overview/security/integrated-windows-authentication)**: An option that Windows applications can use to leverage the underlying security mechanisms on a host in a preferential order. Often, this is [Kerberos Authentication](https://learn.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview) under the hood

> **Note**: Traditionally, Windows applications (developed using [.NET](https://learn.microsoft.com/en-us/entra/msal/dotnet/acquiring-tokens/desktop-mobile/integrated-windows-authentication) or [Universal Windows Platform (UWP)](https://learn.microsoft.com/en-us/windows/uwp/get-started/universal-application-platform-guide)) use Integrated Windows Authentication.

Once the application has authenticated, it can run queries on Active Directory, including validating credentials tied to other domain user accounts and accessing authorizations of a domain user account.

## How does a system administrator typically run an internal application as a Windows service using a gMSA?

1. A **system administrator** authenticates themselves with Active Directory using their own credentials.
2. A **system administrator** runs a command that instructs the Windows host to use a particular gMSA to start the internal application as a service.
3. On deployment, the **internal application** can **authenticate** as the gMSA after retrieving the gMSA's credentials or acquiring an IWA token, which enables it to query Active Directory. Once starts, it offers up an endpoint for unauthenticated users to login through.
4. On attempting to authenticate a user, a **user** provides their username and password to the application. The application uses its own credentials to **authenticate** itself as an **authorized user** on Active Directory, which establishes a connection that the application can use to search for this user. This search identifies the distinguished name of the user from the provided username. The application then passes the user's distinguished name and password to authenticate the user.

> **Note**: The system administrator needs the authorization to start applications using that gMSA.

### Chain of Trust

The important part to take away from the above summary is that there is a [**chain of trust**](https://en.wikipedia.org/wiki/Chain_of_trust) established through this process, which is what **authorizes** the internal application to execute authentication requests.

Namely:

- The application is **authorized** to make LDAP requests since it has provided credentials to **authenticate** as the gMSA
- The application can **authenticate** as the gMSA since a system administrator **authorizes** the application to use that gMSA (and the runtime uses that authorization to retrieve the gMSA's credentials or IWA token)
- The system administrator is **authorized** to create applications that assume gMSAs, so they need to **authenticate** themselves (by logging in) and execute the command to launch the application.

Active Directory implicitly trusts the application to perform authentication requests because it believes an **authenticated, authorized user launched the application**.
