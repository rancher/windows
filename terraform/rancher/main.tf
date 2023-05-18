# Create the Rancher instance
resource "random_string" "rancher_password" {
  length = 20
}

locals {
  rancher_password = random_string.rancher_password.result
}

module "infrastructure" {
  source = "../internal/server"

  name = "${var.name}-rancher"

  server = {
    name  = "docker"
    image = "linux"
    scripts = [
      <<-EOT
      curl https://releases.rancher.com/install-docker/${var.docker_version}.sh | sh
      return=1; while [ $return != 0 ]; do sleep 2; docker ps; return=$?; done
      EOT
      ,
      <<-EOT
      ${var.replace ? "REPLACE=\"${timestamp()}\"" : "unset REPLACE"}
      VOLUME_COMMAND=""
      if docker inspect rancher 1>/dev/null 2>/dev/null; then
        container_id=$(docker stop rancher)
        docker rm -f rancher-data || true
        if [ -z "$REPLACE" ]; then
          docker create --volumes-from rancher --name rancher-data $(docker inspect rancher --format="{{ .Config.Image }}")
          VOLUME_COMMAND="--volumes-from rancher-data"
        fi
        docker rm $container_id
      fi

      docker run -d --restart=unless-stopped $VOLUME_COMMAND \
      --name rancher \
      -p 80:80 -p 443:443 -p 6443:6443 \
      --privileged \
      -e "CATTLE_BOOTSTRAP_PASSWORD=${local.rancher_password}" \
      ${var.registry_hostname}/rancher:v${var.rancher_version}
      EOT
    ]
    open_ports = [80, 443, 6443]
  }

  infrastructure      = var.infrastructure
  ssh_public_key_path = var.ssh_public_key_path
}

resource "digitalocean_record" "rancher_dns" {
  count = var.create_record ? 1 : 0

  domain = "cp-dev.rancher.space"
  type   = "A"
  name   = "${var.name}-rancher"
  value  = local.rancher_ip
}

locals {
  rancher_ip = module.infrastructure.infrastructure.machines["docker"].public_ip

  server_url = "https://${var.create_record ? digitalocean_record.rancher_dns[0].fqdn : local.rancher_ip}"

  rancher_logs = join("'sudo docker logs rancher -f'", matchkeys(split("'",
    module.infrastructure.infrastructure.machines["docker"].ssh_command
  ), [true, false, true], [true]))
}

# Output information to access

output "rancher" {
  value = merge(module.infrastructure.infrastructure, {
    server_url       = local.server_url
    rancher_password = local.rancher_password
    rancher_logs     = local.rancher_logs
  })
}
