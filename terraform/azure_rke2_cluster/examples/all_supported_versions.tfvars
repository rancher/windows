nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["etcd", "controlplane", "worker"]
    replicas = 1
  },
  {
    name     = "windows-2022-core-worker"
    image    = "windows-2022-core"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "windows-2019-core-worker"
    image    = "windows-2019-core"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "windows-2022-worker"
    image    = "windows-2022"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "windows-2019-worker"
    image    = "windows-2019"
    roles    = ["worker"]
    replicas = 1
  }
]
