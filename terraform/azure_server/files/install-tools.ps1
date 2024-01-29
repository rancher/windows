if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    throw "Please install chocolatey first"
}

if (-not (Get-Command refreshenv -ErrorAction SilentlyContinue)) {
    throw "Could not find refreshenv. Something is wrong with your chocolatey installation."
}

$null = refreshenv

$tools = @("go", "git", "kubernetes-cli")

foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "$tool is already installed." -ForegroundColor Green
        continue
    }
    Write-Host "Installing $tool..." -ForegroundColor Green
    choco install $tool -y;
}

$gitHelpersPsm1 = @'
function Clone-Repo {
    param (
    [Parameter(Position=0)]
    [string]$RepoName
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
    [string]$RepoName
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
'@

$profileFilePath = $PROFILE.AllUsersCurrentHost
$profileFileDirectory = Split-Path -Path $profileFilePath
$gitHelpersPsm1Path = Join-Path -Path $profileFileDirectory -ChildPath "Rancher.git_helpers.psm1"

Set-Content -Path $gitHelpersPsm1Path -Value $gitHelpersPsm1

# Point to script to setup git helpers in profile

if (!(Test-Path -Path $PROFILE.AllUsersCurrentHost)) {
    New-Item -ItemType File -Force -Path $PROFILE.AllUsersCurrentHost
}

$profileFile = Get-Content -Path $PROFILE.AllUsersCurrentHost
$addScriptToPathCmd = "Import-Module -WarningAction Ignore -Name ""$gitHelpersPsm1Path"""
if ($profileFile -ne $null) {
    $profileFile = $profileFile.Replace($addScriptToPathCmd, "")   
}
$profileFile = $addScriptToPathCmd + [Environment]::Newline + $profileFile
$profileFile = $profileFile.TrimStart([Environment]::Newline).TrimEnd([Environment]::Newline) + [Environment]::Newline

Set-Content -Path $PROFILE.AllUsersCurrentHost -Value $profileFile

# Load newly created profile

. $PROFILE.AllUsersCurrentHost
