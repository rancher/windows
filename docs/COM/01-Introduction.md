# Component Object Model  

Microsoft's Component Object Model (COM) is a *standard* which applications can use for inter-process communication (IPC) with other COM *components* (also referred to as COM *objects*). COM provides an abstraction layer between different components, simplifying how components interact with one another.


Initially released as COM, Microsoft later improved the standard which resulted in COM+, which enables the use of COM components across networked environments, provides call transactions, better security policies, and more.


This documentation will refer to COM and COM+ interchangeably, and will not focus on more advanced aspects of COM. However, regardless of the features used, modern COM components are always considered COM+ components.


Historically, Microsoft created COM as the foundational software required to support a Windows technology titled 'object linking and embedding' (OLE). The most popular use of OLE is to empower integrated collaboration between Microsoft products, such as Microsoft Word and Microsoft Excel.


Object linking and embedding is what allows users to embed Excel spreadsheets within Word documents in a dynamic manner. OLE ensures that the contents of the spreadsheet are automatically updated in the Word document if a user updates a linked Excel document. This synchronization happens through IPC standardized by COM. COM has other uses outside of OLE, and is a flexible and attractive standard regardless of the use case.


Since COM is a *standard*, and not a framework or as a stand alone technical library, there is no specific language requirement for creating COM components. The sole functional requirement a language must meet to act as a COM component is that it must have a concept of pointers that may be implicitly or explicitly called.


However, while in principle COM is language agnostic, compiling COM components and the required type libraries to use those components relies on core Windows API's. This means that it is easier to implement COM in specific languages, such as C, C++, and C#, which already have utility classes and compilers built into Windows.


Even considering this partial limitation, the language flexibility enables a higher degree of collaboration between independent applications and library vendors. It allows for newer programs written in modern industry standard languages, such as C#, to communicate with legacy libraries and applications seamlessly.


A Major benefit of COM as a standard is that it provides a shared abstraction layer between authors of libraries and applications; The implementation details of a COM component are not accessible and become abstracted through advertised, public, interfaces. A COM component comprises a number of interfaces, ordered within a 'Virtual Method Table'. These interfaces provide a powerful abstraction that allows developers to update or rewrite their component without causing errors or disruptions in other programs which rely on their component.


However, because there is a strong dependence on a set of *stable* public interfaces, it is challenging to change the interface properties once released. This is further complicated as COM components are commonly packaged as Dynamic Link Libraries (DLL). Dynamic Link Libraries are prone to drastic changes when recompiled with even minor internal methods and interface changes, and not properly preparing callers of these changes can result in what is often referred to as ['DLL Hell'](https://en.wikipedia.org/wiki/DLL_Hell).


This expectation of stability goes both ways, When developing a COM component which will interact with another *existing* COM component, properly arranging the code in a way that satisfies the caller expectations is critical.


## COM Clients, Servers, and the COM Virtual Method Table

COM components which invoke other COM components are `COM Clients`, and the component invoked is a `COM Server`. A COM component may be a Server, Client, or both.


COM servers can be one of two types: *in-process* servers and *out-of-process* servers. *In-process* servers are DLL files, executed within the same process as the caller. *Out-of-process* components are EXE files and, as the name implies, do *not* run within the same process as the caller. *Out-of-process* COM servers are special in that they support component calls *over a network*, and covers situations where the server may not be running on the same machine as the client.


When a COM component acts as a COM server, it advertises one or more *interfaces*. Each interface includes an Interface Identifier (IID) annotation, and optionally a human-readable program ID. Clients use these interfaces to identify and invoke the methods packaged within a COM server.


When interacting with a COM server, a client will obtain a reference to the servers `Virtual Method Table` (VTable), which lists all the advertised interfaces for a COM server.


Each VTable provides a Query method which allows callers to retrieve interfaces using their IIDs. This means that callers of a COM server do not need to understand the order in which interfaces appear within the VTable, however, they *do* need to know what the IID of each interface is ahead of time. In situations where a component contains a single interface, then the IID becomes irrelevant, as the caller can index into the interface array directly.


At the data level, a VTable is a pointer to an array of pointers which *are themselves arrays of pointers*. The first array outlines the available interfaces within the Server, and the subsequent array provides a means of accessing the methods within each interface.


In a similar manner as how interfaces contain an IID, classes implementing an interface also contain a GUID annotation. This annotation is the Class ID (CLSID). The caller uses the CLSID to identify and instantiate an instance of the concrete class implementing the interface (referred to as a `coClass`). A COM server may provide multiple coClasses which implement the same interface, and proper use of the CLSID ensures that a caller has the opportunity to use the most appropriate coClass.


Once a COM client has obtained a `coClass` for a given interface, it can start to utilize the methods embedded within the COM server.
