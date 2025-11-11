# install_active_directory turns the VM into an active directory domain controller and creates the relevant forrests.
# Once installed, the script will intitiate a reboot.

$domainName = "${domain_name}"
$domainNetbiosName = "${netbios_name}"
$safeModeAdminstratorPassword = ConvertTo-SecureString "${password}" -AsPlainText -Force
Import-Module ADDSDeployment

if ((Get-WindowsFeature -Name DHCP).InstallState -eq "Installed") {
    try {
        Write-Output "Disabling DHCP functionaltiy..."
        Remove-WindowsFeature -Name DHCP -IncludeManagementTools -Restart:$false
    } catch {
        Write-Host "Hit an error disabling DHCP: $_"
        exit 1
    }
}

Write-Output "Waiting for 10 seconds for the AD Domain information to become available..."
Start-Sleep 10

Write-Output "Checking OS Product Type..."

$osProductType = Get-ComputerInfo | Select -ExpandProperty OsProductType

Write-Output "Found OS Product Type: $osProductType"

if ($osProductType -eq "DomainController") {
    Write-Output "Active Directory is already set up."
} else {
    Write-Output "Registering this computer as an Active Directory Domain Controller..."

    Install-ADDSForest -DomainName "$domainName" -DomainNetBiosName "$domainNetbiosName" -SafeModeAdministratorPassword $safeModeAdminstratorPassword -Force -NoRebootOnCompletion
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false -Force;";
}
