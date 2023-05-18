distribution = "rke1"
rke1_version = "v1.20.15-rancher2-1"
# rke1_version = "v1.20.15-rancher2-2"
cni = "flannel"

nodes = [
  {
    name     = "server"
    image    = "linux"
    roles    = ["controlplane", "etcd", "worker"]
    replicas = 1
  },
  {
    name     = "windows"
    image    = "windows"
    roles    = ["worker"]
    size     = "Standard_F4"
    replicas = 1
  }
]