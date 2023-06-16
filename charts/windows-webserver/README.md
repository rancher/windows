# windows-webserver

This is a simple Helm chart that deploys the `windows/servercore` image (sourced by default from the [Microsoft Artifact Registry](https://mcr.microsoft.com/)) and runs a simple webserver on a Windows node in a cluster.

## Installing

To install this chart on a cluster with **Windows 2019 hosts (default)**, from the root of this repository, run the following command from a terminal that has your `KUBECONFIG` environment set up to point to your target Windows cluster:

```bash
helm install -n default windows-webserver ./charts/windows-webserver
```

If you are running this on a cluster with **Windows 2022 hosts**, please make sure you update the image tag accordingly!

```bash
helm install -n default windows-webserver --set 'image.tag=ltsc2022' ./charts/windows-webserver
```
