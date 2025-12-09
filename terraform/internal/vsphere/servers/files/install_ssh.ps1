Write-Output "Checking if SSH is installed..."
$sshCapability = Get-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';

if ($sshCapability.State -ne "Installed") {
    Write-Output "Installing SSH..."
    Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0';
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;"
} else {
    Write-Output "SSH is already installed."
}
