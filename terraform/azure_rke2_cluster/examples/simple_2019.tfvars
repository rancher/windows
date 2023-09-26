nodes = [
  {
    name     = "linux-server"
    image    = "linux"
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
