nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    roles    = ["etcd", "controlplane", "worker"]
    replicas = 1
  },
  {
    name     = "windows-worker"
    image    = "windows-2019-core"
    roles    = ["worker"]
    replicas = 1
  }
]