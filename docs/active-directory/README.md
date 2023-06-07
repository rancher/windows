# Active-Directory Documentation

This directory contains documentation for various aspects of Microsoft's Active Directory. Each directory focuses on a 
particular topic and contains multiple markdown files focusing on discrete parts of the topic. Files are written
in such a way that they can be read in the same manner as a book, with earlier sections introducing concepts used in 
later sections - while still being easily linkable when needed. 

## Topics

+ Core-Concepts
  + The core concepts that should be known when working with Active Directory. This covers the basics of Forests, 
    Domains, and other objects tracked by Active Directory.
+ Group Managed Service Accounts (gMSA)
  + Specifics regarding a popular service account offered by Active Directory. Additionally, this topic contains information
    on related aspects of Windows, such as the Container Credential Guard and how specific container runtimes provide
    functionality to support the use of a gMSA in containerized environments. 