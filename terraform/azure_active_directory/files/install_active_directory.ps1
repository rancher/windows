$domainName = "${domain_name}"
$domainNetbiosName = "${netbios_name}"
$safeModeAdminstratorPassword = ConvertTo-SecureString "${password}" -AsPlainText -Force

Write-Output "Installing Windows Feature for AD-Domain-Services..."

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment

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
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";
}
