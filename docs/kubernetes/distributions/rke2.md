# RKE2

RKE2 (Rancher Kubernetes Engine) is a [Kubernetes distribution](./provisioning.md#distributions) offered by Rancher.

RKE2 supports adding Windows nodes to create mixed OS clusters with both Windows and Linux nodes.

### How does RKE2 work?

Under the hood, RKE2 is simply a different "flavor" of k3s.

The primary difference between RKE2 and k3s from a design perspective is that k3s focuses on **edge** use-cases, whereas RKE2 focuses on security and compliance within the U.S. Federal Government sector, which is why it's often also called **RKE Government**.

In addition, RKE2 supports adding Windows nodes by using [wins](../provisioning/wins.md) to install components onto the host prior to the establishment of a Kubernetes cluster (at which point [HostProcess](https://kubernetes.io/blog/2022/12/13/windows-host-process-containers-ga/) pods may be used).

You can generally assume that **most** of the design of RKE2 applies to k3s, since it uses k3s under the hood; therefore, for more details, please refer to the docs on [k3s](./k3s.md).
