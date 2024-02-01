if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host 'choco is already installed.' -ForegroundColor Green
} else {
    Write-Host 'Installing choco...' -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
}

$null = Import-Module "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1"

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
