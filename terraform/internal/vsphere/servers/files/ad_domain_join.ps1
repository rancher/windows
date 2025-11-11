# ad_domain_join.ps1 installs the required features and uses templated AD credentials to join a VM to an AD domain.
# Important requirements for joining a Domain are, 1. The DC must be the primary DNS server, 2. The RSAT-AD-Tools are required
# to use any of the AD commands

# Ensure single quotes are used, as double quotes may result in an
# attempt to expand nonexistent variables or execute commands via $()
$domainName = '${domain_name}'
$machineUsername = '${machine_username}'
$machinePassword = '${machine_password}'
$activeDirectoryUsername = '${domain_netbios_name}\${active_directory_username}'
$activeDirectoryPassword = '${active_directory_password}'
$activeDirectoryServer = '${active_directory_server}'

Write-Output "Pointing DNS client to active directory DNS server..."
# Find the primary ipv4 interface. Its index is not determinate in our vsphere environment.
$ips = get-netipaddress -addressfamily ipv4
$interfaceIndex = 0
foreach($ip in $ips) {
    if ($ip.InterfaceAlias -like "*Ethernet0 2*") {
        $interfaceIndex = $ip.InterfaceIndex
        break
    }
}

$dns = Get-DnsClientServerAddress -InterfaceIndex $interfaceIndex -AddressFamily IPv4
$updatedDNS = @($activeDirectoryServer) + $dns.ServerAddresses
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses $updatedDNS

Write-Output "Installing Windows Feature RSAT-AD-Tools..."
Install-WindowsFeature -Name RSAT-AD-Tools

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
        Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false -Force;";
    }
};
