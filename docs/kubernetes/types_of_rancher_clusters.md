# Types of Rancher Clusters

Rancher mainly supports the following three types of clusters.

## Provisioned

A **provisioned** cluster is a cluster provisioned by Rancher's built-in machine provider and bootstrapped by Rancher into a Kubernetes cluster.

## Custom

A **custom** cluster is a cluster with nodes provisioned external to Rancher (such as by a Terraform module) and bootstrapped by Rancher into an Kubernetes cluster.

## Imported

An **imported** cluster is a Kubernetes cluster provisioned external to Rancher entirely.

On imported clusters, Rancher provides a cluster registration command that runs a `kubectl apply` to deploy a daemon that allows it to communicate with the cluster (i.e. `cattle-cluster-agent`).

This daemon reaches out to Rancher at a **publicly accessible** URL and establishes a [Layer 4 reverse tunnel connection](https://github.com/rancher/remotedialer), which allows Rancher to communicate with the cluster even in situations where the cluster exists within an **air-gapped setup** (an environment whose network denies all inbound connections and also may heavily restrict what outbound connections are strictly allowed for security purposes).
