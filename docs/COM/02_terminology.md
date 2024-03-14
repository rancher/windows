# Terminology

## COM Servers and Clients

A **COM server** is a COM component that advertises interfaces.

These interfaces each have methods that **COM clients** invoke.

> **Note**: A COM server can also be a COM client.

In particular, there are two types of COM servers:

- **In-process (`.dll`)**: These COM servers provide methods executed within the **same processes** as the COM client that calls it.
- **Out-of-process (`.exe`)**: These COM servers provide methods executed in **their own process**. They support calls over a network / across machines.

## Globally Universally Unique Identifier (GUIDs)

A [GUID](https://learn.microsoft.com/en-us/windows/win32/api/guiddef/ns-guiddef-guid) is a unique 128-bit value.

GUIDs are 32 hexadecimal digits separated by dashes in the format `AAAAAAAA-BBBB-CCCC-DDDD-DDDDDDDDDDDD`.

- `Data1` is the 8 digit `AAAAAAAA`.
- `Data2` is the 4 digit `BBBB`
- `Data3` is the 4 digit `CCCC`
- `Data4` is the remaining 16 `DDDD-DDDDDDDDDDDD`

**Classes**, **interfaces**, and **types** all use GUIDs to identify themselves.

## COM Class (`coClass`)

A **COM class (`coClass`)** is a concrete implementation of one or more interfaces that COM clients can instantiate. Each COM server offers one or more COM classes.

Every COM Class has a unique **class ID (CLSID)**, which is a [GUID](#globally-universally-unique-identifier-guids).

## COM Interfaces

An **COM interface** is how a COM server exposes its functionality as **methods** that a COM client can invoke. A COM component implements at least one COM class for every interface it defines.

**Interface identifiers (IIDs)** identify interfaces (along with optionally human-readable program ID). IIDs are [GUIDs](#globally-universally-unique-identifier-guids).

When a COM client reaches out to a COM server, it typically needs both the CLSID (to identify the COM server) and the IID (to identify the interface) to actually invoke a function call.

> **Note**: Interfaces provide a **shared abstraction layer** between authors of libraries and applications since the implementation details of a COM component are not accessible and become abstracted through advertised, public, interfaces.
>
> Interfaces allow developers to update or rewrite their component without causing errors or disruptions in other programs which rely on their component.

## Virtual Method Tables (`vtable`)

A **Virtual Method Table (`vtable`)** is an array of pointers to methods.

When a COM client reaches out to a COM server, the client obtains a reference to the COM class's `vtable`.

The `vtable` will expose the [`QueryInterface`](https://learn.microsoft.com/en-us/windows/desktop/api/unknwn/nf-unknwn-iunknown-queryinterface(q)) method, which retrieves pointers to other interfaces supported by the COM class.

> **Note**: Why does the COM class have the `QueryInterface` method?
>
> The first three methods on every `vtable` of a COM Class is always associated with the [IUnknown interface](https://learn.microsoft.com/en-us/windows/win32/api/unknwn/nn-unknwn-iunknown): `QueryInterface`, `AddRef`, and `Release`.

Given a pointer to a particular interface, the COM client can then invoke particular **methods** belonging to that interface.

 This means that COM clients do not need to understand the order in which interfaces appear within the `vtable`, but they do need to know what the IID of each interface is ahead of time.

> **Note**: In situations where a component contains a single interface, then the IID becomes irrelevant, as the caller can index into the interface array directly.
