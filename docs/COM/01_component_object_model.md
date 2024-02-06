# Component Object Model (COM)

## What is COM?

**Component Object Model (COM)** is a standard developed by Microsoft that applications can use for inter-process communication (IPC) with other COM **components** (also referred to as **COM objects**).

COM provides an abstraction layer between different components, simplifying how components interact with one another.

## What is COM+?

[COM+](https://learn.microsoft.com/en-us/windows/win32/cossdk/component-services-portal) is the new standard developed by Microsoft.

COM+ has more features, such as:

- Better support for resource management tasks like thread allocation or security
- Support for transactions
- Support for using COM components across networked environments

Modern COM components are always considered COM+ components.

## Why was COM built?

Historically, Microsoft created COM as the foundational software required to support a Windows technology called [object linking and embedding (OLE)](https://learn.microsoft.com/en-us/cpp/mfc/ole-background?view=msvc-170).

The most popular use of OLE is to empower integrated collaboration between Microsoft products, such as Microsoft Word and Microsoft Excel.

For example, by using OLE, you could embed a **dynamic** Excel spreadsheet within a Word document, which meant that OLE would ensure the contents of the spreadsheet are automatically updated in the Word document if a user updates a linked Excel document.

## How are COM components written?

While COM was primarily created for C/C++, the modern approach to developing COM components is using C# with [.NET Framework](https://dotnet.microsoft.com/en-us/learn/dotnet/what-is-dotnet-framework).

For example, see [here](./03_com_with_c_sharp.md).

## Do you need to write COM components in C/C++/C#?

While the language you write a COM application in must have a concept of pointers that may be implicitly or explicitly called, there is no specific language required for creating COM components.

But compiling COM components and the required type libraries to use those components relies on core Windows APIs, so it's easier to create COM objects in specific languages such as C/C++/C# that already have utility classes and compilers built into Windows.



