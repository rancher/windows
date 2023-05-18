locals {
  ssh_public_key = file(var.ssh_public_key_path)

  calicoctl_version = "v3.19.2"
  etcdctl_version   = "v3.4.16"

  servers = concat(
    [for v in var.cluster.servers : merge(v, {
      registration_script = "echo \"Nothing to do.\""
      subnet              = "external"
    })],
    flatten([
      for v in var.cluster.machine_pools : [
        for i in range(0, v.replicas) :
        merge(v, {
          name   = "${v.name}-${i}"
          index  = i
          subnet = join("-", sort(v.roles))
          registration_script = trimspace(format("%s %s",
            substr(v.image, 0, length("windows")) != "windows" ?
            "${var.cluster.linux_registration_command}" : "${var.cluster.windows_registration_command}",
            substr(v.image, 0, length("windows")) != "windows" ?
            join(" ", [for role in v.roles : "--${role}"]) : "",
          )),
          scripts = [for v in concat([
            // set up SSH for Windows
            substr(v.image, 0, length("windows")) == "windows" ? <<-EOT
            Start-Service sshd;
            Set-Service -Name sshd -StartupType 'Automatic';
            Add-Content -Path 'C:\ProgramData\ssh\administrators_authorized_keys' -Value '${local.ssh_public_key}';
            icacls.exe 'C:\ProgramData\ssh\administrators_authorized_keys' /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F';
            EOT
            : null,
            // set profile for nodes
            substr(v.image, 0, length("windows")) != "windows" ? <<-EOT
            cat >> /etc/profile <<EOF
            export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
            export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
            export PATH="$PATH:/var/lib/rancher/rke2/bin"
            sudo /var/lib/rancher/rke2/bin/crictl config --set runtime-endpoint=unix:///run/k3s/containerd/containerd.sock
            alias k=kubectl
            EOF
            EOT
            : <<-EOT
            @"
            [Environment]::SetEnvironmentVariable(
                "Path",
                [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin",
                [EnvironmentVariableTarget]::Machine)
            Set-Item -Path Env:\CRI_CONFIG_FILE -Value "C:\var\lib\rancher\rke2\agent\etc\crictl.yaml"
            Set-Item -Path Env:\CONTAINER_RUNTIME_ENDPOINT -Value "npipe:////./pipe/containerd-containerd"
            "@ | Out-File -FilePath "$PSHOME\Profile.ps1"
            EOT
            ,
            // install calicoctl on all linux nodes
            substr(v.image, 0, length("windows")) == "windows" ? null :
            !contains(v.roles, "etcd") && !contains(v.roles, "controlplane") ? null : <<-EOT
            curl -o /usr/local/bin/calicoctl -O -L  "https://github.com/projectcalico/calicoctl/releases/download/${local.calicoctl_version}/calicoctl" 
            chmod +x /usr/local/bin/calicoctl
            EOT
            ,
            // install etcdctl only on etcd linux nodes
            substr(v.image, 0, length("windows")) == "windows" ? null :
            !contains(v.roles, "etcd") ? null : <<-EOT
            wget https://github.com/etcd-io/etcd/releases/download/${local.etcdctl_version}/etcd-${local.etcdctl_version}-linux-amd64.tar.gz
            tar -xvzf etcd-${local.etcdctl_version}-linux-amd64.tar.gz etcd-${local.etcdctl_version}-linux-amd64/etcdctl 
            mv etcd-${local.etcdctl_version}-linux-amd64/etcdctl /usr/local/bin/etcdctl

            cat >> /etc/profile <<EOF
            export ETCDCTL_ENDPOINTS='https://127.0.0.1:2379';
            export ETCDCTL_CACERT='/var/lib/rancher/rke2/server/tls/etcd/server-ca.crt';
            export ETCDCTL_CERT='/var/lib/rancher/rke2/server/tls/etcd/server-client.crt';
            export ETCDCTL_KEY='/var/lib/rancher/rke2/server/tls/etcd/server-client.key';
            export ETCDCTL_API=3;
            EOF
            EOT
          ], v.scripts) : v if v != null]
        })
      ]
    ])
  )
}

module "images" {
  source = "../images"

  infrastructure_provider = var.infrastructure.azure.enabled ? "azure" : ""
}

locals {
  source_images = module.images.source_images
}

module "azure" {
  count = var.infrastructure.azure.enabled ? 1 : 0

  source = "../azure"

  group               = var.cluster.name
  ssh_public_key_path = var.ssh_public_key_path

  location = var.infrastructure.azure.location
  network = {
    template = "${var.cluster.distribution}-${var.cluster.cni}"
  }

  servers = [for server in local.servers : merge(server, {
    image = {
      publisher = local.source_images[server.image].publisher
      offer     = local.source_images[server.image].offer
      sku       = local.source_images[server.image].sku
      version   = local.source_images[server.image].version
      os        = local.source_images[server.image].os
    }
    boot_scripts = concat(local.source_images[server.image].scripts, server.boot_scripts)
    scripts      = server.scripts
  })]
}

output "infrastructure" {
  value = merge(
    module.azure...
  )
}