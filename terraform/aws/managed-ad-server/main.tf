provider "aws" {
    region                  = var.aws_region
    shared_credentials_file = var.aws_credentials_file
    profile                 = var.aws_profile
}

resource "random_integer" "this" {
    min = 1
    max = 99999
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_directory_service_directory" "rancher_eng_ad" {
  name       = "ad-${random_integer.this.result}.rancher-eng.rancherlabs.com"
  password   = random_password.this.result
  type       = "MicrosoftAD"
  alias      = "ad-${random_integer.this.result}"
  enable_sso = true

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
        Name  = "var.vpc_name-subnet-a"
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
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

output "aws_managed_ad_url" {
    description = "Access URL of the new AWS Directory Service Managed Active Directory Server"
    value = aws_directory_service_directory.rancher_eng_ad.access_url
}

output "aws_managed_ad_password" {
    description = "Administrator password for managing the new AWS Directory Service Managed Active Directory Server"
    value = random_password.this.result
}

output "aws_managed_ad_dns" {
    description = "List of DNS Servers for the new AWS Directory Service Managed Active Directory Server"
    value = [aws_directory_service_directory.rancher_eng_ad[*].dns_ip_addresses]
}
