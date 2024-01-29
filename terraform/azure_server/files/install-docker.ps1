$dockerService = Get-Service -Name Docker -ErrorAction "SilentlyContinue"
if ($dockerService.Status -eq 'Running') {
    Write-Host 'docker is already installed.' -ForegroundColor Green
    exit 0
}

$dockerVersion = "24.0.7"
$dockerURL = "https://download.docker.com/win/static/stable/x86_64/docker-$dockerVersion.zip"

Write-Host "Downloading Docker from $dockerURL..."

(New-Object System.Net.WebClient).DownloadFile($dockerURL, "$env:TEMP\docker.zip")
Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:TEMP -Force

Write-Host "Installing Docker CE..."

(New-Object System.Net.WebClient).DownloadFile(
    "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1", 
    "$env:TEMP\install-docker-ce.ps1"
)
& "$env:TEMP\install-docker-ce.ps1" -DockerPath "$env:TEMP\docker\docker.exe" -DockerDPath "$env:TEMP\docker\dockerd.exe"
