$sshPublicKey = "${ssh_public_key}"

Write-Output "Checking if SSH is running..."
$sshdService = Get-Service sshd

if ($sshdService.Status -ne "Running") {
    Write-Output "Starting SSH..."
    Start-Service sshd;
} else {
    Write-Output "SSH is already started."
}

Set-Service -Name sshd -StartupType 'Automatic';

Write-Output "Checking if SSH public key has already been added..."
$keyIsPresent = $false
$authorizedKeys = Get-Content -Path 'C:\ProgramData\ssh\administrators_authorized_keys' -ErrorAction SilentlyContinue
foreach ($key in $authorizedKeys) {
    if ($key -eq $sshPublicKey) {
        Write-Output "Found SSH Public key."
        $keyIsPresent = $true
        break
    }
}

if (-not $keyIsPresent) {
    Write-Output "Adding SSH Public key..."
    Add-Content -Path 'C:\ProgramData\ssh\administrators_authorized_keys' -Value "$sshPublicKey";
    icacls.exe 'C:\ProgramData\ssh\administrators_authorized_keys' /inheritance:r /grant 'Administrators:F' /grant 'SYSTEM:F';
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;"
}
