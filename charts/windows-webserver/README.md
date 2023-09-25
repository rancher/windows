# windows-webserver

This is a simple Helm chart that deploys the `windows/servercore` image (sourced by default from the [Microsoft Artifact Registry](https://mcr.microsoft.com/)) and runs a simple webserver on a Windows node in a cluster.

## Installing

To install or upgrade this chart on a cluster with **Windows 2019 hosts (default)**, from the root of this repository, run the following command from a terminal that has your `KUBECONFIG` environment set up to point to your target Windows cluster:

```bash
helm upgrade --install -n default windows-webserver ./charts/windows-webserver
```

If you are running this on a cluster with **Windows 2022 hosts**, please make sure you update the image tag accordingly!

```bash
helm upgrade --install -n default windows-webserver --set 'image.tag=ltsc2022' ./charts/windows-webserver
```

## Testing

The path for this webserver within the Kubernetes API Server is `/api/v1/namespaces/default/services/http:windows-webserver:80/proxy/`.

To test that the webserver is working:

### In Rancher

1. Identify your cluster's API Server URL: `API_SERVER_URL=https://<RANCHER_IP>/k8s/clusters/c-m-<CLUSTER_ID>`
2. Go to `${API_SERVER_URL}/api/v1/namespaces/default/services/http:windows-webserver:80/proxy/`

### Other Clusters

1. Create a proxy to the API Server using kubectl proxy: `kubectl proxy --port=8080`
2. Go to `http://localhost:8080/api/v1/namespaces/default/services/http:windows-webserver:80/proxy/`

## State of Support

**The Rancher Windows team does not support this Helm chart in any official capacity.**

Community members should note this Helm chart is **never intended for use in any production environment** and is **subject to breaking changes at any point of time**.

The primary audience for this Helm chart is **members of the Rancher Windows team** who require this Helm chart to reproduce setups that mimic supported environments.
