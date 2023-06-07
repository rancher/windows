# gMSA In Kubernetes

The scenario described in the last section is not only a good example of when and how to inject gMSA details into a 
container, is also the perfect use case for a Kubernetes deployment as we would benefit from deploying multiple replica’s.

Similar to how the container runtime provides a credential spec flag when running a container, Kubernetes allows users 
to provide that same information within a pods security context - under the `windowsOptions` section. This value can be
provided in plain text JSON, or by using a CRD custom-built for this purpose. This CRD is introduced alongside a
dedicated gMSA web-hook which makes the process of passing this information to deployments much simpler.

## gMSA Web-hook and Plugin

### gMSA Web-hook

Kubernetes leverages the behavior within the container runtime within the `windowsOptions` field of a security context
for a deployment. Users can specify the gMSA details as a JSON blob within the `gmsaCredentialSpec` field, which is
then passed to the container runtime directly without the use of any intermediary CRD’s. The value passed would have the
same format as that seen in the ‘gMSA in Docker / Containerd’ section.

Managing these JSON strings and placing them onto each definition can be cumbersome and prone to human error. To address
this issue the Kubernetes SIG developed a gMSA CRD and a mutating and validating web-hook.

The new CRD is called a `GMSACredentialSpec`. This resource defines each attribute of the JSON formatted gMSA credential
spec, and offers greater ease of management with almost no possibility of human error as it is a CRD which needs to only
be defined once. Each gMSA account can have one of these resources defined for it, and this resource can be used for
many workloads at once.

```yaml
# An Example of a GMSA Credential Spec Object
apiVersion: windows.k8s.io/v1
kind: GMSACredentialSpec
metadata:
  name: example-gmsa-WebApp1 
credspec:
  ActiveDirectoryConfig:
    GroupManagedServiceAccounts:
    - Name: WebApp1      #Username of the GMSA account
      Scope: CONTOSO     #NETBIOS Domain Name
    - Name: WebApp1      #Username of the GMSA account
      Scope: contoso.com #DNS Domain Name
  CmsPlugins:
  - ActiveDirectory
  DomainJoinConfig:
    DnsName: contoso.com  #DNS Domain Name
    DnsTreeName: contoso.com #DNS Domain Name Root
    Guid: 244818ae-87ac-4fcd-92ec-e79e5252348a  #GUID
    MachineAccountName: WebApp1 #Username of the GMSA account
    NetBiosName: CONTOSO  #NETBIOS Domain Name
    Sid: S-1-5-21-2126449477-2524075714-3094792973 #SID of GMSA
```

The gMSA web-hook itself is quite simple and has two core responsibilities:

1. Validate: It ensures that the service account used to create the deployment has RBAC access to the
   `GMSACredentialSpec` object - this is merely a simple RBAC check used to control access to the CRD.
2. Mutate: It expands the content of that CRD onto a pod spec created by a deployment. This expansion process is where
   any chance of human error is removed, as well as an additional level of security when viewing the deployment YAML as
   the contents of the gMSA are not visible. At the end of the day, the pod spec will contain the JSON encoded gMSA
   credential spec object seen previously, it’s just a matter of how it is placed there.

A deployment with a gMSA credential security context looks like the following

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: with-creds
  name: with-creds
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      run: with-creds
  template:
    metadata:
      labels:
        run: with-creds
    spec:
      securityContext:
        windowsOptions:
          gmsaCredentialSpecName: example-gmsa-webapp1
      containers:
      - image: mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019
        imagePullPolicy: Always
        name: iis
      nodeSelector:
        kubernetes.io/os: windows
```

### gMSA Web-hook Considerations

This web-hook is very useful for creating deployments which need to leverage gMSA’s, but it  should be treated in the
same manner as any other critical web-hook. It is configured with a ‘Fail’ policy by default, meaning that if no
instances of the web-hook are available all cluster operations will be blocked by Kubernetes. This event is recoverable,
as you can simply remove the web-hook configuration manually and retry the operation, however this problem should not be
disregarded when deciding on how to use gMSA within Kubernetes.

While this web-hook makes managing and passing gMSA details to containers quite easy, they do not address a larger
architectural requirement when integrating Kubernetes clusters into an Active Directory environment. Due to the fact
that a host must contact a Domain Controller in order to get the gMSA password, any host used as a Kubernetes node
which can be scheduled to run a gMSA workload must be joined into the Active Directory Domain for which that
gMSA account is valid.

While not an overly complicated process, joining a host to a domain is not a one-step action and requires a restart of
the host. In auto-scaling environments this can be a dealbreaker, as complicated automation is needed to properly
achieve what should be a reliable and native Kubernetes concept.

Microsoft, in response to this scenario, developed a way to retrieve a gMSA password without having to join a node into
an Active Directory domain. This ‘plugin’ functionality is leveraged by Azures AKS and AWS EKS to solve the auto-scaling
problem for their paying customers. While not well documented, plugins may be written by other developers to achieve the
same outcome outside AKS.