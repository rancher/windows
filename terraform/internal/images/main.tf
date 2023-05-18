output "source_images" {
  value = var.infrastructure_provider == "azure" ? local.azure_source_images : null
}