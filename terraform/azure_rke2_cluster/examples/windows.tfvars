nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    scripts  = []
    roles    = ["etcd", "controlplane", "worker"]
    replicas = 1
  },
  {
    name     = "windows-worker"
    image    = "windows-2019-core"
    scripts  = []
    roles    = ["worker"]
    replicas = 1

  }
]
