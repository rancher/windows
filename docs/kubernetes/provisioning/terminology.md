# Terminology

## Machine Pools (Rancher)

A Machine Pool represents a subset of nodes in your cluster that **all have the same node-level machine configuration**.

Each Machine Pool is associated with an `<Infrastructure>Config` CR that contains all the configuration for the pool (including what roles the nodes in this pool should take within the Kubernetes cluster).

Each `<Infrastructure>Config` CR also references an `<Infrastructure>MachineTemplate` CR that specifies the cloud provider specific configuration details; multiple `<Infrastructure>Config` can reference the same `<Infrastructure>MachineTemplate`.

A cluster may have one or more Machine Pools associated with it. A common configuration is to have one Machine Pool whose Machines take on all of the Kubernetes roles (`controlplane`, `etcd`, `worker`) and one Machine Pool whose Machines take on only the `worker` role. These can both be tied to a single `<Infrastructure>MachineTemplate`.

> **Note**: Rancher Machine Pools are **have nothing to do with** (currently) experimental [CAPI Machine Pools](https://cluster-api.sigs.k8s.io/tasks/experimental-features/machine-pools.html), which are **not currently implemented by Rancher**.

## Node Drivers



## "Parent" and "Child" Objects

Provisioning V2 leverages the [`apply` module of `rancher/wrangler`](https://github.com/rancher/wrangler/tree/master/pkg/apply) is to create and manage "child" objects from a single "parent" object.

Essentially, a single "parent" object declares a `desiredSet` of resources that should be tied to it. The objects in this `desiredSet` are the expected "child" objects for this "parent".

On applying a `desiredSet`, Rancher will utilize annotations on the object to identify it as part of this `desiredSet`. This will later be used to handle reconcile logic on the next apply.

On running the `Apply` operation on that "parent" object with a set of new objects:
- Objects in the cluster under the old `desiredSet` but not in the new `desiredSet` are **deleted**
- Objects in the `desiredSet` but not in the cluster under the old `desiredSet` are **created**
- Objects in both the cluster and the new `desiredSet` are **patched**, if necessary

> **Note**: Why does apply using annotations instead of [Owner References](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/)?
>
> Owner References requires the dependent object to be within the same namespace, but apply can be used to manage child objects across namespaces (or even to manage child resources that are non-namespaced / global).

