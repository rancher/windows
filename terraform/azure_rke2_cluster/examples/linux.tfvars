nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["etcd", "controlplane", "worker"]
    replicas = 1
  },
  {
    name     = "linux-worker"
    image    = "linux"
    roles    = ["worker"]
    replicas = 1
  }
]