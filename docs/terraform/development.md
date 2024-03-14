# Setting up a Rancher development environment

To set up an environment to develop on Rancher Windows repositories, you can take the following steps.

## Initial Setup

Initialize all the Terraform modules used in this guide:

```bash
terraform -chdir=terraform/azure_server init
```

> **Note**: Windows requires an RSA-based SSH key pair.

### Connecting to Azure

The Terraform modules used in this guide assume that the user has already authenticated their current machine to Azure by following the guidance of the [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

### Using VSCode Remote Explorer (optional)

For developers who use VSCode, it may be useful to install the [Remote Explorer extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer), which makes it far easier to launch terminals or view files on a remote machine.

## Provision a Windows development server

To provision a Windows development server in Azure, run the following Terraform command at the root of this repository to create an [Windows server with Rancher Developer Tools installed](../../terraform/azure_server):

```bash
TF_NAME_PREFIX="clippy-test"

terraform -chdir=terraform/azure_server apply -var="name=${TF_NAME_PREFIX}-server" -var-file="examples/windows_dev.tfvars"
```

## Setting up repositories

Once all initialization scripts have finished running, your Windows host should have the following tools installed:

1. [chocolatey (choco)](https://chocolatey.org/)
2. [git](https://git-scm.com/)
3. [go](https://golang.org/)
4. [kubernetes-cli (kubectl)](https://community.chocolatey.org/packages/kubernetes-cli)
5. [docker](https://www.docker.com)
6. [containerd](https://containerd.io/)
7. [WSL (Ubuntu 1804)](https://learn.microsoft.com/en-us/windows/wsl/about)

> **Note**: To enable WSL, you may have to run the following command manually while logged in as `adminuser`:
>
> `& C:\Windows\System32\wsl\ubuntu1804.exe install --root`
>
> After running this command, you should be able to run `bash` to hop into the WSL terminal.

It also adds two PowerShell functions to your profile:

1. `Clone-Repo <repository>`: this function takes in a repository like `rancher/windows` and clones it to the path `C:\go\src\github.com\<repository>` directory on your host.
2. `Go-Repo <repository>`: given a repository in the same format as `Clone-Repo` expects (i.e. `rancher/windows`), this changes your current working directory to `C:\go\src\github.com\<repository>`

To install all the basic windows Repositories on your host, run the following command:

```powershell
Clone-Repo rancher/wins
Clone-Repo rancher/windows
Clone-Repo rancher/Rancher-Plugin-gMSA
```
