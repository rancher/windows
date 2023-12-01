# C# and COM

> **Note**
>
> Terms and concepts in this document rely on an understanding of COM itself. If you are unfamiliar with COM, first read [this documentation](./01-Introduction.md)

To better understand how to implement a COM component, we will take the [CCGRKC](github.com/rancher/rancher-plugin-gmsa) plugin as an example and discuss its contents.


```C#
using System.EnterpriseServices;
using System.Runtime.InteropServices;

namespace my.com.namespace
{
    [Guid("6ECDA518-2010-4437-8BC3-46E752B7B172")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [ComImport]
    public interface ICcgDomainAuthCredentials
    {
        void GetPasswordCredentials(
            [MarshalAs(UnmanagedType.LPWStr), In] string pluginInput,
            [MarshalAs(UnmanagedType.LPWStr)] out string domainName,
            [MarshalAs(UnmanagedType.LPWStr)] out string username,
            [MarshalAs(UnmanagedType.LPWStr)] out string password);
    }

    [Guid("e4781092-f116-4b79-b55e-28eb6a224e26")]
    [ProgId("CcgCredProvider")]
    public class CcgCredProvider : ServicedComponent, ICcgDomainAuthCredentials
    {
        void GetPasswordCredentials(
            [MarshalAs(UnmanagedType.LPWStr), In] string pluginInput,
            [MarshalAs(UnmanagedType.LPWStr)] out string domainName,
            [MarshalAs(UnmanagedType.LPWStr)] out string username,
            [MarshalAs(UnmanagedType.LPWStr)] out string password)
            {
              ...
            }
    }
}
```

The above example describes a COM *Server*, designed for use by the Windows Container Credential Guard (CCG). As such, the structure matches what CCG expects. When implementing COM servers for existing COM clients, the structuring of the application is crucial.

## The COM interface

```C#
    [Guid("6ECDA518-2010-4437-8BC3-46E752B7B172")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [ComImport]
    public interface ICcgDomainAuthCredentials
    {
        void GetPasswordCredentials(
            [MarshalAs(UnmanagedType.LPWStr), In] string pluginInput,
            [MarshalAs(UnmanagedType.LPWStr)] out string domainName,
            [MarshalAs(UnmanagedType.LPWStr)] out string username,
            [MarshalAs(UnmanagedType.LPWStr)] out string password);
    }
```

In the above example, we declare a single COM interface named `ICcgDomainAuthCredentials`. It has an Interface Identifier (IID) of `6ECDA518-2010-4437-8BC3-46E752B7B172`, and declares the `[ComImport]` annotation. `[ComImport]` indicates that the type information for this interface will be manually provided through additional annotations on the interface.

> **Note**
> This example comes from a COM component specifically designed for the Windows Container Credential Guard, which expects a single interface, and as such, the IID is actually arbitrary and does not have a meaningful impact on functionality. Nevertheless, once published, a COM component should avoid changing its GUID properties unless required.


After defining the type and identity information of the Interface, `IccgDomainAuthCredentials` defines a single method, titled `GetPasswordCredentials`. This is a void method, where the caller must retrieve the output via the same pointers it passed when invoking the method.

## Implementing the CoClass

```C#
    [Guid("e4781092-f116-4b79-b55e-28eb6a224e26")]
    [ProgId("CcgCredProvider")]
    public class CcgCredProvider : ServicedComponent, ICcgDomainAuthCredentials
    {
        void GetPasswordCredentials(
            [MarshalAs(UnmanagedType.LPWStr), In] string pluginInput,
            [MarshalAs(UnmanagedType.LPWStr)] out string domainName,
            [MarshalAs(UnmanagedType.LPWStr)] out string username,
            [MarshalAs(UnmanagedType.LPWStr)] out string password)
            {
              ...
            }
    }
```


For each defined Interface, a COM component needs to provide at least one concrete class which implements that interface. This concrete class, or coClass, contains additional annotations which help identify it to the caller of the component. At least the `[Guid]` annotation must exist, otherwise the caller would need to index directly within the VTable to create the coClass. Indexing directly is a brittle way of accessing an interface coClass, as future versions of the component cannot ensure the current ordering of the VTable. The `[ProgId]` annotation is optional, and while callers may use the property to instantiate the coClass, it is more susceptible to collisions with other coClasses which may inadvertently use the same `[ProgId]`.


The `CcgCredProvider` class extends one additional class and one interface: the `ServicedComponent` class, and the initial interface, `ICcgDomainAuthCredentials`. The `ServicedComponent` class plays a special role in the creation of the coClass. Much like the earlier `IUnknown` interface, `ServicedComponent` provides the boilerplate logic for the coClass, as well as the ability to set the above-mentioned `[Guid]` and `[ProgId]` attributes. `ServicedComponent` also provides base implementations of COM Pooling, transaction management, and context sharing between the component and .NET. COM components written in C# must extend this class.



The `CcgCredProvider` class goes on to define an implementation of the `GetPasswordCredentials` method. The contents of this method are arbitrary, so long as it sets a value for the `domainName` `username` and `password` parameters.
