# Note: It's expected that you are running this terraform command from the root of this repository for this file to work
# i.e. run `terraform -chdir=terraform/internal/rancher/bundle ...`
name = "windows-webserver"
path = "charts/windows-webserver"
values = {
  image = {
    repository = "windows/nanoserver"
  }
}
