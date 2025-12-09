$dockerService = Get-Service -Name docker -ErrorAction "SilentlyContinue"
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

$executables = @("docker", "dockerd")
foreach ($executable in $executables) {
    Move-Item -Path "$env:TEMP\docker\$executable.exe" -Destination "$env:windir\System32\$executable.exe" -Force
}

New-Item "$env:ProgramData\docker\config" -ItemType Directory -ErrorAction SilentlyContinue
@{} | ConvertTo-Json | Out-File -FilePath "$env:ProgramData\docker\config\daemon.json" -Encoding ASCII

Add-MpPreference -ExclusionProcess "$env:windir\System32\dockerd.exe"

& "$env:windir\System32\dockerd.exe" --register-service --service-name docker
Start-Service -Name docker
