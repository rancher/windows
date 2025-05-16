# Ensure single quotes are used, as double quotes may result in an
# attempt to expand nonexistent variables or execute commands via $()
$domainName = '${domain_name}'
$machineUsername = '${machine_username}'
$machinePassword = '${machine_password}'
$activeDirectoryUsername = '${domain_netbios_name}\${active_directory_username}'
$activeDirectoryPassword = '${active_directory_password}'
$networkPrefixLength = '${network_prefix_length}'

Write-Output "Installing Windows Feature RSAT-AD-Tools..."
Install-WindowsFeature -Name RSAT-AD-Tools

Write-Output "Setting subnet mask prefix length to $networkPrefixLength..."
Set-NetIPAddress -InterfaceAlias "Ethernet" -PrefixLength "$networkPrefixLength"

$localCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = "$machineUsername"
    Password = (ConvertTo-SecureString -String "$machinePassword" -AsPlainText -Force)[0]
})

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = "$activeDirectoryUsername"
    Password = (ConvertTo-SecureString -String "$activeDirectoryPassword" -AsPlainText -Force)[0]
})

$computerInfo = Get-WmiObject Win32_ComputerSystem;
if ($computerInfo.PartOfDomain) {
    Write-Output "Computer is already part of domain $($computerInfo.Domain).";
} else {
    Write-Output "Adding computer to domain $domainName..."
    Add-Computer -DomainName "$domainName" -Credential $joinCred -LocalCredential $localCred
    if ($? -eq $true) {
        Write-Host "Restarting this host after a successful domain join operation...";
        Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";
    }
};
