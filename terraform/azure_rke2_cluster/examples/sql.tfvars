nodes = [
  {
    name     = "linux-server"
    image    = "linux"
    size     = "Standard_B4als_v2"
    roles    = ["controlplane", "etcd", "worker"]
    replicas = 1
  },
  {
    name     = "windows-worker"
    image    = "windows-2022"
    roles    = ["worker"]
    replicas = 1
  }
]

servers = [
  {
    name  = "sql-server"
    image = "windows-2022"
    // A SQL server should always be domain joined
    domain_join = true
    sql_server  = true
  }
]

// Ports which should not be exposed to the internet
vpc_only_ports = [
  // SQL server API
  "1433",
]
