nodes = [
  {
    name     = "linux-etcd"
    image    = "linux"
    roles    = ["etcd"]
    replicas = 1
  },
  {
    name     = "linux-controlplane"
    image    = "linux"
    roles    = ["controlplane"]
    replicas = 1
  },
  {
    name     = "linux-worker"
    image    = "linux"
    roles    = ["worker"]
    replicas = 1
  },
  {
    name     = "windows-worker"
    image    = "windows"
    roles    = ["worker"]
    replicas = 1
  }
]