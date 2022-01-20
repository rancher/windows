provider "aws" {
    region                  = var.aws_region
    shared_credentials_file = var.aws_credentials_file
    profile                 = var.aws_profile
}

resource "random_integer" "this" {
    min = 1
    max = 99999
}

data "http" "myipv4" {
  url = "http://whatismyip.akamai.com/"
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.aws_region}-windows-ad-mgmt"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "pem" {
  filename = format("%s/%s", "${path.root}/keys", "${aws_key_pair.this.key_name}.pem") 
  sensitive_content = tls_private_key.ssh_key.private_key_pem
}

resource "aws_directory_service_directory" "rancher_eng_ad" {
  # name       = "ad-${random_integer.this.result}.rancher-eng.rancherlabs.com"
  name       = "rancher-eng.rancherlabs.com"
  password   = random_password.this.result
  type       = "MicrosoftAD"
  alias      = "ad-${random_integer.this.result}"
  short_name = "rancher-eng"
  enable_sso = false

  vpc_settings {
    vpc_id     = aws_vpc.main.id
    subnet_ids = [aws_subnet.a.id, aws_subnet.b.id]
  }

  tags = {
    Project = "SUSE Rancher Dev/QA Active Directory"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
      Name        = "${var.owner}-vpc"
      Owner       = var.owner
      DoNotDelete = "true"
    }
}

resource "aws_subnet" "a" {
    vpc_id            = aws_vpc.main.id
    availability_zone = data.aws_availability_zones.available.names[0]
    cidr_block        = "10.0.1.0/24"
    tags = {
        Owner = var.owner
        Name  = "${var.vpc_name}-subnet-a"
    }
}

resource "aws_subnet" "b" {
    vpc_id            = aws_vpc.main.id
    availability_zone = data.aws_availability_zones.available.names[1]
    cidr_block        = "10.0.2.0/24"
    tags = {
        Owner = var.owner
        Name  = "${var.vpc_name}-subnet-b"
    }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags = {
    Owner = var.owner
    Name  = "${var.vpc_name}-ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpc_dhcp_options" "this" {
  depends_on = [
    aws_directory_service_directory.rancher_eng_ad
  ]
  domain_name         = aws_directory_service_directory.rancher_eng_ad.name
  domain_name_servers = aws_directory_service_directory.rancher_eng_ad.dns_ip_addresses

  tags = {
    Name = "${var.owner}-dhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-ContainersLatest-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_security_group" "windows" {
    name   = "${var.owner}_windows_mgmt"
    vpc_id = aws_vpc.main.id
    tags = {
      Owner       = var.owner
      DoNotDelete = "true"
    }
    ingress {
      description = "Inbound RDP from local"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myipv4.body)}/32"]
      # ipv6_cidr_blocks = [aws_vpc.main_vpc.ipv6_cidr_block]
    }
    ingress {
      description = "Inbound ssh from local"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myipv4.body)}/32"]
      # ipv6_cidr_blocks = ["${chomp(data.http.myipv6.body)}"]
    }
    ingress {
      description = "Inbound winrm from local"
      from_port   = 5986
      to_port     = 5986
      protocol    = "tcp"
      cidr_blocks = ["${chomp(data.http.myipv4.body)}/32"]
      # ipv6_cidr_blocks = ["${chomp(data.http.myipv6.body)}"]
    }
}


resource "aws_instance" "windows" {
  count = 1
  tags = {
    Name        = "${var.prefix}-windows-ad-mgmt"
    Owner       = var.owner
    DoNotDelete = "true"
  }

  key_name                    = aws_key_pair.this.key_name
  ami                         = data.aws_ami.windows_2019.id
  instance_type		            = "m5.xlarge"
  associate_public_ip_address = "true"
  subnet_id                   = aws_subnet.a.id
  vpc_security_group_ids      = [aws_vpc.main.default_security_group_id, aws_directory_service_directory.rancher_eng_ad.security_group_id, aws_security_group.windows.id]
  get_password_data           = "true"
  source_dest_check           = "false"
  user_data            =  base64encode(templatefile("${path.root}/files/userdata-windows.yml", { ec2launchv2_config_b64 = filebase64("${path.root}/files/agent-config.yml"), windows_password = var.windows_admin_password}))
# ad_domain = format("%s",aws_directory_service_directory.rancher_eng_ad.name), ad_dns_0 = format ("%s",aws_directory_service_directory.rancher_eng_ad.dns_ip_addresses[0]), ad_dns_1 = format ("%s",aws_directory_service_directory.rancher_eng_ad.dns_ip_addresses[1]),
  root_block_device {
    volume_size = 100
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}

# resource "aws_network_interface_sg_attachment" "this" {
#   depends_on = [
#     aws_instance.windows
#   ]
#   count = length(aws_instance.windows)
#   security_group_id    = aws_security_group.windows.id
#   network_interface_id = element(aws_instance.windows.*.primary_network_interface_id, count.index)
# }

data "template_file" "decrypted_keys" {
  count = length(aws_instance.windows)
  template = rsadecrypt(element(aws_instance.windows.*.password_data, count.index), tls_private_key.ssh_key.private_key_pem)
}

locals {
  bastion_username   = "Administrator"
  path               = "dc=ranger-eng,dc=rancherlabs,dc=com"
  group_name         = "test group"
  sam_account_name   = "TESTGROUP"
}

# remote using NTLM authentication and HTTPS
provider "ad" {
  winrm_hostname = aws_instance.windows[0].public_dns
  winrm_username = local.bastion_username
  winrm_password = data.template_file.decrypted_keys[0].rendered
  winrm_use_ntlm = true
  winrm_port     = 5986
  winrm_proto    = "https"
  winrm_insecure = true
  krb_conf       = templatefile("${path.root}/files/krb5.tftpl", { fqdn = aws_directory_service_directory.rancher_eng_ad.name, bastion_private_ip = aws_instance.windows[0].private_ip, bastion_public_ip  = aws_instance.windows[0].public_ip, short_name = aws_directory_service_directory.rancher_eng_ad.short_name })
}

module "populate" {
  depends_on = [
    aws_directory_service_directory.rancher_eng_ad
  ]
  # providers = {
  #   ad = ad
  # }
  source = "./modules/populate-ad"
  path = local.path
  domain = aws_directory_service_directory.rancher_eng_ad.name
  ad_group_name = local.group_name
  ad_sam_name = local.sam_account_name
}
