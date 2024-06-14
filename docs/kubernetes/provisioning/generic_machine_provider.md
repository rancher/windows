# Generic Machine Provider

The Generic Machine Provider can be thought of as a "meta-infrastructure provider"; a provider of infrastructure providers (called **Node Drivers** in Rancher) that all share the same underlying controllers but individually do the provisioning for each infrastructure by leveraging the driver-specific provisioning logic in [rancher/machine](./repositories.md#rancher-machine).

## Registering Node Drivers

On Rancher's startup, Rancher encodes the specific list of drivers from `rancher/machine` it supports by creating the corresponding `NodeDriver` CRs in the management cluster. 

These `NodeDriver` CRs primarily contain the driver's name, some metadata fields, and some small options unrelated to `rancher/machine`.

On seeing a `NodeDriver` CR be created, Rancher's controllers automatically create a `DynamicSchema` CR that is created by grabbing the driver name from the `NodeDriver` CR and making a call to `rancher/machine` to get the create flags for that specific driver.

These create flags are then directly converted into the `DynamicSchema` CR's spec fields and persisted into the cluster.

Finally, on seeing the creation of a `DynamicSchema` CR, Provisioning V2 controllers kick in to automatically convert a `DynamicSchema` into a  `<Infrastructure>Config` CRD that serves as the Infrastructure Provider CRD for that driver.

> **Note**: Why do we convert to `NodeDriver` and then to `DynamicSchema` instead of directly creating the CRDs?
>
> `NodeDrivers` are an essential part of Rancher's Provisioning V1 solution used to create [RKE](https://www.rancher.com/products/rke), Rancher's legacy Kubernetes distribution that has been replaced by `k3s` / `RKE2`.
>
> Therefore, to avoid duplicated code, we directly create `DynamicSchema`s on seeing `NodeDrivers` be created.

## Provisioning Nodes

On `<Infrastructure>Machine` creation, the Machine Provider converts it into a Kubernetes Job that runs the `rancher/machine` image, where the configuration of the machine exactly matches the CLI args we intend to pass into the machine image.

For example:

1. On creating an InfrastructureMachine: `rancher-machine create --secret-name=<secret-name> --secret-namespace=<secret-namespace> --driver=<driver> <additional-driver-args <instance-name>`

2. On deleting an InfrastructureMachine: `rancher-machine rm --secret-name=<secret-name> --secret-namespace=<secret-namespace> -y --update-config <instance-name>`

To save the configuration, any Machine Job that is done is tied to a pre-defined Secret known as the **Machine State Secret** (provided in the arguments shown above).

This Machine State Secret is expected to live for as long as the Machine does and should not be deleted.

> **Note**: The machine image is defined in the Rancher environment variable `CATTLE_MACHINE_PROVISION_IMAGE`, which is also a Rancher setting that can be modified after spinning up Rancher.

Since this Machine State Secret also contains the SSH credentials provided by `rancher/machine` on provisioning a node, Rancher can support SSHing into a node after provisioning it.