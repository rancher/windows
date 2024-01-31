
$toolsPsm1 = @'
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
$toolsPsm1Path = Join-Path -Path $profileFileDirectory -ChildPath "rancher_tools.psm1"

Set-Content -Path $toolsPsm1Path -Value $toolsPsm1

# Point to script to setup git helpers in profile

if (!(Test-Path -Path $PROFILE.AllUsersCurrentHost)) {
    New-Item -ItemType File -Force -Path $PROFILE.AllUsersCurrentHost
}

$profileFile = @"
`$env:PATH += ";C:\ProgramData\chocolatey\bin"

`$null = Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
`$null = refreshenv
`$null = Import-Module -WarningAction Ignore -Name `"$toolsPsm1Path`"

Set-Item -Path Env:\CRI_CONFIG_FILE -Value `$env:ProgramData\crictl\crictl.yaml
"@
Set-Content -Path $PROFILE.AllUsersCurrentHost -Value $profileFile

# Load newly created profile

. $PROFILE.AllUsersCurrentHost
