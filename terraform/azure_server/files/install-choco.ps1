if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host 'choco is already installed.' -ForegroundColor Green
} else {
    Write-Host 'Installing choco...' -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";
}
