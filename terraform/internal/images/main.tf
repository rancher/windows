module "azure" {
  count = var.infrastructure_provider == "azure" ? 1 : 0
  source = "../azure/images"
}

output "source_images" {
  value = merge(
    module.azure[0].source_images
  )
}