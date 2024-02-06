# C# and COM

## Example Application (CCG Plugin)

Let's take a look at an example COM server for a Windows Container Credential Guard (CCG) plugin written in C#:

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

## `ICcgDomainAuthCredentials` (Interface)

`ICcgDomainAuthCredentials` is a COM interface (identified by `[ComImport]`) with the IID `6ECDA518-2010-4437-8BC3-46E752B7B172` that supports `GetPasswordCredentials`, a method that takes in string pointers and fills in the string value at those pointers when invoked.

It extends the `IUnknown` interface (implemented by every COM class), which provides the `QueryInstance` method.

> **Note**: In this particular case, the IID of the interface is irrelevant, since Microsoft's CCG documentation expects CCG Plugin to expose one interface that it directly indexes into.
>
> Indexing directly is a brittle way of accessing an interface of a COM class, as future versions of the component cannot ensure the current ordering of the VTable.

## `CcgCredProvider` (Class)

`CcgCredProvider` is a COM class identified by the CLSID `e4781092-f116-4b79-b55e-28eb6a224e26` and a human-readable `[ProgId]` annotation.

> **Note**: In theory, callers could use the `[ProgId]` value to instantiate the class, but this is more susceptible to collisions with other COM classes that use the same `[ProgId]`.

It implements the `ICcgDomainAuthCredentials` interface and extends the [`ServicedComponent`](https://learn.microsoft.com/en-us/dotnet/api/system.enterpriseservices.servicedcomponent?view=netframework-4.8) class.


> **Note**: `ServicedComponent` provides boilerplate logic for every COM class, including base implementations of COM Pooling, transaction management, and context sharing between the component and .NET. It's also what allows us to set the `[Guid]` and `[ProgId]` attributes
>
> COM components written in C# **must** extend this class.

The `CcgCredProvider` class implements the `GetPasswordCredentials` method. The contents of this method are arbitrary, so long as it sets a value for the `domainName` `username` and `password` parameters.
