$restart = $false

$requiredFeatures = @("containers", "Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform", "Microsoft-Hyper-V")
foreach ($feature in $requiredFeatures) {
    $state = $(Get-WindowsOptionalFeature -Online -FeatureName $feature).State
    if ($state -eq "Enabled") {
        Write-Host "$feature is installed." -ForegroundColor Green
        continue
    }
    $restart = $true
    Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
}

# First install of choco will fail, it's just to install .NET Framework
try {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host 'choco is already installed.' -ForegroundColor Green
    } else {
        $restart = $true
        Write-Host 'Installing choco...' -ForegroundColor Green
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    }
} finally {
    if ($restart) {
        Write-Host "Restarting host..." -Foreground Green
        Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";
    }
}
