# Windows Support Across Cloud Providers

This document tracks the images that the Rancher Windows team recognizes as official Windows images on supported cloud providers.

The Rancher Windows team has a goal to add automated infrastructure in the [`terraform/`](../terraform/) directory to support provisioning clusters in these cloud providers for developer test setups.

The Rancher Windows team supports Windows clusters provisioned using [RKE2](https://github.com/rancher/rke2).

- [Azure](https://support.microsoft.com/en-us/topic/windows-server-images-for-january-2022-51a88228-17f6-422d-a593-b09ff9f20632)
  - `Windows Server, version 2022`
  - `Windows Server 2019`
- [GCP](https://cloud.google.com/compute/docs/images/os-details#windows_server )
  - `windows-2022`
  - `windows-2022-core`
  - `windows-2019`
  - `windows-2019-for-containers`
  - `windows-2019-core`
  - `windows-2019-core-for-containers`
- [vsphere](https://github.com/phillipsj/vsphere-templates-for-rancher)
  - `Microsoft Windows Server 2022 (Standard)`
  - `Microsoft Windows Server 2022 (Datacenter)`
  - `Microsoft Windows Server 2019 (Standard)`
  - `Microsoft Windows Server 2019 (Datacenter)`
- [AWS](https://aws.amazon.com/windows/resources/amis/)
  - `Microsoft Windows Server 2019 Base`
  - `Microsoft Windows Server 2019 Core`

> **Note**: No **official** supported version of Windows Server 2022 exists in AWS at the time of writing this document.
