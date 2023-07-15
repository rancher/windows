# Azure Images Terraform

This [Terraform](https://www.terraform.io/) module contains the supported images used to spin up servers in Azure via Terraform.

## Listing all images

```bash
terraform -chdir=terraform/internal/azure/images plan
```

## Finding new images

To add a new image to this module, update the [`linux.yaml`](./files/linux.yaml) or [`windows.yaml`](./files/windows.yaml) with an entry for your desired image.

To get all VM images on Azure, run the following command on the `az` CLI:

```bash
REGION=westus

az vm image list -l ${REGION} -o yaml
```

To get all the images (note: this can take a long time so it's recommended to redirect the output into a file):

```bash
REGION=westus
OUTPUT_PATH=azure-images.yaml

az vm image list -l ${REGION} -o yaml --all > ${OUTPUT_PATH}
```

## Adding new images

For each entry in the YAML files:

- The **key** is the alias we're using the refer to the image
- The **value** is an object containing 4 attributes:
  - **publisher** (retrieved from Azure CLI command output)
  - **offer** (retrieved from Azure CLI command output)
  - **sku**, or [Stock Keeping Unit](https://www.investopedia.com/terms/s/stock-keeping-unit-sku.asp) (retrieved from Azure CLI command output)
  - **scripts** that will run on loading the VM to prepare it for use (provided by the developer)

> **Note**: The `linux.yaml` expects scripts in **Bash**. The `windows.yaml` expects scripts in **PowerShell**.

## State of Support

**The Rancher Windows team does not support these Terraform modules in any official capacity.**

Community members should note that modules contained in this directory are **never intended for use in any production environment** and are **subject to breaking changes at any point of time**.

The primary audience for this Terraform is **members of the Rancher Windows team** who require these modules to reproduce setups that mimic supported environments.
