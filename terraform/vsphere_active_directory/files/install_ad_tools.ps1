# install_ad_tools.ps1 installs the features required to setup Active Directory.
# This is done in an independent file as these features require a reboot, and it is
# not possible to resume a scheduled task mid execution after a reboot.
Write-Output "Installing Windows Feature for AD-Domain-Services..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false -Force;";
