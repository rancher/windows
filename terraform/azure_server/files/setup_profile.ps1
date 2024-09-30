
$toolsPsm1 = @'
function Clone-Repo {
    param (
        [Parameter(Position=0)]
        [string]
        $RepoName
    )

    # If the repository name does not contain a slash, assume repository is rancher/$RepoName
    if ($RepoName -notmatch '/') {
        $RepoName = "rancher/$RepoName"
    }

    # Define the directory where the repository will be cloned
    $dir = "/go/src/github.com/$RepoName"

    git clone "https://github.com/$RepoName.git" $dir
}

function Go-Repo {
    param (
        [Parameter(Position=0)]
        [string]
        $RepoName
    )

    # If the repository name does not contain a slash, assume the user wants to go to /go/src/github.com/rancher/$RepoName
    if ($RepoName -notmatch '/') {
        $RepoName = "rancher/$RepoName"
    }

    # Define the directory where the repository is located
    $dir = "/go/src/github.com/$RepoName"

    # Check if the directory exists
    if (Test-Path -Path $dir) {
    # Change to the directory
    Set-Location -Path $dir
    } else {
    Write-Host "The directory $dir does not exist."
    }
}

function Get-RemoteFile {
    param (
        [Parameter()]
        [string]
        $RemoteDrive,

        [Parameter(Mandatory)]
        [string]
        $File,

        [Parameter(Mandatory)]
        [string]
        $Destination
    )

    if ($RemoteDrive -eq "" ) {
        Write-Host "RemoteDrive parameter was omitted, defaulting to 'windows'"
        $RemoteDrive = "windows"
    }

    Import-Module BitsTransfer
    Start-BitsTransfer \\tsclient\$RemoteDrive\$File -Destination $Destination -Description "Downloading $File from remote drive $RemoteDrive" -DisplayName $File
}

'@

# Create a powershell module to include useful functions.

# Note: A Powershell module must be placed in a default module path, such as
#
#   C:\Users\adminuser\Documents\WindowsPowerShell\Modules
#   C:\Program Files\WindowsPowerShell\Modules
#   C:\Windows\system32\WindowsPowerShell\v1.0\Modules

# Or if an additional path is desired, it must be created and added to $env:PsModulePath

# A module must be placed inside a directory with the name of that module (e.g. "RancherTools")
# and the module file must match the module directory name ("RancherTools.psm1").
# Modules can be imported by name using "Import-Module -Name <ModuleName>".

# The scheduled task does not use the standard user created by terraform (adminuser)
# so the $PROFILE variable should not be used.
$profileFileDirectory = "C:\Users\adminuser\Documents\WindowsPowerShell"
if (-not (Test-Path $profileFileDirectory)) {
    New-Item -ItemType Directory -Force -Path $profileFileDirectory
}

$toolsModulePath = $profileFileDirectory + "\Modules\" + "RancherTools"
if (-not (Test-Path -Path $toolsModulePath)) {
    New-Item -ItemType Directory -Force -Path $toolsModulePath
}

$toolsPsm1Path = Join-Path -Path $toolsModulePath -ChildPath "RancherTools.psm1"
Set-Content -Path $toolsPsm1Path -Value $toolsPsm1

$profileFile = @"
`Import-Module -WarningAction Ignore -Name RancherTools

`$env:PATH += ";C:\Applications\Scoop\shims"

Set-Item -Path Env:\CRI_CONFIG_FILE -Value `$env:ProgramData\crictl\crictl.yaml
"@

$profileFilePath = Join-Path -Path $profileFileDirectory -ChildPath "Microsoft.PowerShell_profile.ps1"

# Note: This will overwrite any content stored in the profile
Set-Content -Path $profileFilePath -Value $profileFile

# Load newly created profile
. $profileFilePath
