locals {
  linux_images   = yamldecode(file("${path.module}/files/linux.yaml"))
  windows_images = yamldecode(file("${path.module}/files/windows.yaml"))

  default_linux_image   = "ubuntu-1804"
  default_windows_image = "windows-2019"

  source_images = {
    for k, v in merge(
      { for k, v in merge(local.linux_images, {
        // set default
        linux = local.linux_images[local.default_linux_image]
      }) : k => merge(v, { os = "linux" }) },
      { for k, v in merge(local.windows_images, {
        // set default
        windows = local.windows_images[local.default_windows_image]
      }) : k => merge(v, { os = "windows" }) },
    ) :
    k => merge(v, { version = "latest" })
  }
}


output "source_images" {
  value = local.source_images
}