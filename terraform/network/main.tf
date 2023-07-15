module "azure" {
  source = "../internal/azure/images"
}

locals {
  source_images = {
    azure = module.azure.source_images
  }
}

output "source_images" {
  value = local.source_images
}