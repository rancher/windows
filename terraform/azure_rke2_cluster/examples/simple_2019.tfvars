nodes = [
  {
    name  = "linux-server"
    image = "linux"
    scripts = [
      "echo \"hello world\""
    ]
    roles    = ["etcd", "controlplane", "worker"]
    replicas = 1
  },
  {
    name  = "windows-worker"
    image = "windows-2019-core"
    scripts = [
      "Write-Output \"hello world\""
    ]
    roles    = ["worker"]
    replicas = 1
  }
]

servers = [
  {
    name  = "windows-standalone"
    image = "windows"
    scripts = [
      "Write-Output \"hello world\""
    ]
  }
]