Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart;

# Restart host
Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";