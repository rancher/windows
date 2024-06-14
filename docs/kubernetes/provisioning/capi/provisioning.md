# CAPI Provisioning

On a high-level, here is how CAPI provisions clusters after users run a command like `clusterctl generate cluster [name] --kubernetes-version [version] | kubectl apply -f -`:

1. Create cluster-level infrastructure pieces **(handled by [Cluster Infrastructure Provider](./terminology.md#cluster-infrastructure-provider))**

2. **ONLY IF** using `MachineDeployment` / `MachineSet`: Create `Machine`, `<Infrastructure>Machine`, and `<Distribution>Bootstrap` objects resources for each replica requested in the `MachineSet` spec **(handled by CAPI Controllers)**

3. Create a Machine Bootstrap Secret per `<Distribution>Bootstrap` that contains the script that needs to be installed right after provisioning a machine to add it to the Kubernetes cluster **(handled by [Bootstrap Provider](./terminology.md#bootstrap-provider))**

4. Provision a physical server per `<Infrastructure>Machine` by contacting the infrastructure provider (i.e. AWS, Azure, etc.) and running the bootstrap script in the Machine Bootstrap Secret on the machine before marking it as Ready **(handled by [Machine Provider](./terminology.md#machine-infrastructure-provider))**

5. Copy the `<Infrastructure>Machine` fields over to the corresponding CAPI `Machine` **(handled by CAPI Controllers)**

6. Initialize the cluster's controlplane (only once all `Machine`s are marked as Ready) using the configuration on the `<Distribution>ControlPlane` and join the bootstrapped nodes onto the controlplane; once all `Machine`s are joined, create a `KUBECONFIG` that can be used to access the newly provisioned cluster's Kubernetes API **(handled by [ControlPlane Provider](./terminology.md#control-plane-provider))**

7. Copy the `<Distribution>ControlPlane` fields over to the corresponding CAPI `Cluster`, specifically including the control plane endpoint that can be used to communicate with the cluster **(handled by CAPI Controllers)**

Once these steps have been taken, a user can run `clusterctl get kubeconfig` to access the newly provisioned downstream cluster's Kubernetes API.

```mermaid
graph TD
    CAPIControllers("CAPI Controllers\n (copies fields back to Cluster and Machine CRs)")

    subgraph Providers
    ClusterProvider("Cluster Provider")
    BootstrapProvider("Bootstrap Provider")
    MachineProvider("Machine Provider")
    ControlPlaneProvider("Control Plane Provider")
    end

    subgraph Provider CRs
    InfrastructureCluster("&ltInfrastructure&gtCluster")
    DistributionBootstrap("&ltDistribution&gtBootstrap")
    DistributionBootstrapTemplate("&ltDistribution&gtBootstrapTemplate")
    InfrastructureMachine("&ltInfrastructure&gtMachine")
    InfrastructureMachineTemplate("&ltInfrastructure&gtMachineTemplate")
    DistributionControlPlane("&ltDistribution&gtControlPlane")
    end
    
    subgraph Physical Resources
    ClusterInfrastructure("Cluster-Level Infrastructure\n(LoadBalancers, NetworkSecurityGroups, etc.)")
    PhysicalServer("Physical Server")
    MachineBootstrapSecret("Machine Bootstrap Secret\n(Bash script)")
    KubeConfig("KUBECONFIG")
    end

    CAPIControllers--On Cluster Create-->ClusterProvider
    CAPIControllers--Before Machines Create-->BootstrapProvider
    CAPIControllers--On Machines Create-->MachineProvider
    CAPIControllers--On Machines Ready-->ControlPlaneProvider
    
    ClusterProvider-.->InfrastructureCluster
    InfrastructureCluster-.-> ClusterInfrastructure
    BootstrapProvider-.->DistributionBootstrap
    BootstrapProvider-.->DistributionBootstrapTemplate
    DistributionBootstrap-.->MachineBootstrapSecret
    MachineProvider-.->InfrastructureMachine
    InfrastructureMachine-.->PhysicalServer
    MachineProvider-.->InfrastructureMachineTemplate
    ControlPlaneProvider-.->DistributionControlPlane
    DistributionControlPlane-.->KubeConfig
```