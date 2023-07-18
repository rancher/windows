name = "dummy"

registration_commands = {
  linux   = "echo \"This should be replaced with the Linux registration command.\""
  windows = "echo \"This should be replaced with the Windows registration command.\""
}

nodes = [
  {
    name     = "linux-server"
    os       = "linux"
    roles    = ["controlplane", "etcd", "worker"]
    replicas = 1
  },
  {
    name     = "windows-server"
    os       = "windows"
    roles    = ["worker"]
    replicas = 1
  }
]