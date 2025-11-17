# Setting up a Rancher development environment

To set up an environment to develop on Rancher Windows repositories, you can take the following steps.

## Initial Setup

Initialize all the Terraform modules used in this guide:

```bash
terraform -chdir=terraform/vsphere_server init
```

> **Note**: Windows requires an RSA-based SSH key pair.

### Connecting to vSphere

The Terraform modules used in this guide assume that the user has access to a vSphere environment. No other cloud providers are supported at the moment.

### Using VSCode Remote Explorer (optional)

For developers who use VSCode, it may be useful to install the [Remote Explorer extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer), which makes it far easier to launch terminals or view files on a remote machine.

## Provision a Windows development server

To provision a Windows development server in vSphere, create a copy of `terraform/vsphere_server/examples/windows_2022.tfvarsexample` and provide the relevant vSphere configuration information. Once this is done, just run

```bash
terraform -chdir=terraform/vsphere_server apply -var-file="examples/windows_2022.tfvars"
```

## Setting up repositories

Once all initialization scripts have finished running, your Windows host should have the following tools installed:

1. [Scoop](https://chocolatey.org/)
2. [git](https://git-scm.com/)
3. [go](https://golang.org/)
4. [docker](https://www.docker.com)

Depending on the `windows_script_bundle` you've specified, the host may also contain

1. [kubernetes-cli (kubectl)](https://community.chocolatey.org/packages/kubernetes-cli)
2. [containerd](https://containerd.io/)
3. [WSL (Ubuntu 1804)](https://learn.microsoft.com/en-us/windows/wsl/about)

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
