nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["etcd", "controlplane", "worker"]
    replicas = 1
  },
  {
    name     = "windows-worker"
    image    = "windows-2022"
    roles    = ["worker"]
    replicas = 1
  }
]
