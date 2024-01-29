if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    throw "Please install chocolatey first"
}

# Add script to setup choco to path

$setupChocoPs1 = @'
$null = Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
$null = refreshenv

$env:PATH += ";C:\ProgramData\chocolatey\bin"
'@

$profileFilePath = $PROFILE.AllUsersCurrentHost
$profileFileDirectory = Split-Path -Path $profileFilePath
$setupChocoPs1Path = Join-Path -Path $profileFileDirectory -ChildPath "Rancher.setup_choco.ps1"

Set-Content -Path $setupChocoPs1Path -Value $setupChocoPs1

# Point to script to setup choco in profile

if (!(Test-Path -Path $PROFILE.AllUsersCurrentHost)) {
    New-Item -ItemType File -Force -Path $PROFILE.AllUsersCurrentHost
}

$profileFile = Get-Content -Path $PROFILE.AllUsersCurrentHost
$addScriptToPathCmd = "& $setupChocoPs1Path"
if ($profileFile -ne $null) {
    $profileFile = $profileFile.Replace($addScriptToPathCmd, "")   
}
$profileFile = $addScriptToPathCmd + [Environment]::Newline + $profileFile
$profileFile = $profileFile.TrimStart([Environment]::Newline).TrimEnd([Environment]::Newline) + [Environment]::Newline

Set-Content -Path $PROFILE.AllUsersCurrentHost -Value $profileFile

# Load newly created profile

. $PROFILE.AllUsersCurrentHost
