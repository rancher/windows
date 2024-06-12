# Create the Rancher instance
resource "random_string" "rancher_password" {
  length  = 20
  special = false
}

locals {
  rancher_password = random_string.rancher_password.result
}

module "images" {
  source = "../internal/azure/images"
}

module "user" {
  source = "../internal/kubernetes/user"

  api_server_address = "0.0.0.0"
  create_file        = false
}

locals {
  user_script = <<-EOT
  #!/bin/bash

  mkdir -p /etc/rancher-dev/cluster
  cd /etc/rancher-dev/cluster

  until [[ "$(docker inspect -f "{{.State.Running}}" rancher)" -eq "true" ]]; do
    sleep 0.1;
  done;

  cat <<-"SCRPT" | docker exec -i rancher /bin/bash
  
  while true; do
    if ! which kubectl 1>/dev/null; then
      echo "Waiting for kubectl to become available..."
      sleep 2
      continue
    fi
    if ! kubectl cluster-info 1>/dev/null 2>/dev/null; then
      echo "Waiting for apiserver to become available..."
      sleep 2
      continue
    fi
    break
  done

  echo "Waiting for permissions to be set properly in this cluster..."
  sleep 5

  ${replace(module.user.script, "#!/bin/bash", "")}
  SCRPT

  docker cp rancher:/var/lib/rancher/${module.user.name}.kubeconfig /etc/rancher-dev/cluster/${module.user.name}.kubeconfig
  EOT
}

module "server" {
  source = "../internal/azure/servers"

  name = var.name

  network = {
    type = "simple"
    // We hard-code a unique address_space to avoid conflicts with other modules
    // creating a peering relationship with the network created by this module
    address_space = var.address_space
    airgap        = false
    open_ports    = ["80", "443", "6443"]
  }

  servers = [
    {
      name  = var.name
      image = module.images.source_images["linux"]
      size  = var.size
      scripts = [
        templatefile("${path.module}/files/install_docker.sh", {
          docker_version = var.docker_version
        }),
        templatefile("${path.module}/files/install_or_upgrade_rancher.sh", {
          replace            = var.replace ? timestamp() : null
          bootstrap_password = local.rancher_password
          image              = var.image
          agent_image        = var.agent_image
        }),
        local.user_script
      ]
    }
  ]

  ssh_public_key_path = var.ssh_public_key_path
}

resource "digitalocean_record" "rancher_dns" {
  count = var.create_record ? 1 : 0

  domain = "cp-dev.rancher.space"
  type   = "A"
  name   = var.name
  value  = local.rancher_ip
}

locals {
  rancher_ip = module.server.machines[var.name].public_ip

  server_url = var.create_record ? digitalocean_record.rancher_dns[0].fqdn : local.rancher_ip

  rancher_logs = join("'sudo docker logs rancher -f'", matchkeys(split("'",
    replace(module.server.machines[var.name].ssh_command, " -t ", " ")
  ), [true, false, true], [true]))

  rancher_kubeconfig = <<-EOT
  ${join("cat /etc/rancher-dev/cluster/${module.user.name}.kubeconfig", matchkeys(split("'",
  replace(module.server.machines[var.name].ssh_command, " -t ", " ")
), [true, false, true], [true]))} 2>/dev/null | sed 's*0.0.0.0*${local.server_url}*g' > ${var.name}.kubeconfig;
  export KUBECONFIG=$(pwd)/${var.name}.kubeconfig
  EOT
}

# Output information to access

output "rancher" {
  value = merge({
    machines = module.server.machines
    debug    = module.server.debug
    }, {
    server_url         = "https://${local.server_url}"
    rancher_password   = local.rancher_password
    rancher_logs       = local.rancher_logs
    rancher_kubeconfig = local.rancher_kubeconfig
  })
}
