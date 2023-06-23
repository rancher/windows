$scripts = @(${scripts})
$bootScripts = @(${boot_scripts})

$scriptDir = "C:\etc\rancher-dev\cluster"

$entryTaskName = "run_init_scripts_task" 
Remove-Item $scriptDir -Recurse -Force -ErrorAction SilentlyContinue;
Unregister-ScheduledTask -TaskName $entryTaskName -Confirm:`$false -ErrorAction SilentlyContinue;

$entryPs1 = @("Start-Transcript -Path `"$scriptDir\entry.log`"", "Write-Output `"Sleeping for 5 seconds on node reboot`"", "Start-Sleep -Seconds 5", "Write-Output `"Executing scripts...`"")
New-Item -ItemType Directory -Force -Path "$scriptDir";
For ($i=0; $i -lt $scripts.Length; $i++) {
    $destinationPath = Join-Path -Path $scriptDir $scripts[$i]
    $entryPs1 += "Write-Output `"Executing $destinationPath...`""
    $entryPs1 += "& `"$destinationPath`""
    Copy-Item $scripts[$i] -Destination $destinationPath
}
$entryPs1 += "Unregister-ScheduledTask -TaskName $entryTaskName -Confirm:`$false -ErrorAction SilentlyContinue;"

$entryPs1Path = Join-Path -Path $scriptDir entry.ps1
$entryPs1 -join ";`r`n" | Out-File -FilePath $entryPs1Path

$entryTaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -NoLogo -NoProfile -ExecutionPolicy Bypass $entryPs1Path"
$entryTaskTrigger = New-ScheduledTaskTrigger -AtStartup

Register-ScheduledTask -User System -TaskName $entryTaskName -Action $entryTaskAction -Trigger $entryTaskTrigger

$bootPs1 = @("Start-Transcript -Path `"$scriptDir\boot.log`"", "Write-Output `"Executing boot scripts...`"")
For ($i=0; $i -lt $bootScripts.Length; $i++) {
    $destinationPath = Join-Path -Path $scriptDir $bootScripts[$i]
    $bootPs1 += "Write-Output `"Executing $destinationPath...`""
    $bootPs1 += "& `"$destinationPath`""
    Copy-Item $bootScripts[$i] -Destination $destinationPath
}

$bootPs1Path = Join-Path -Path $scriptDir boot.ps1
$bootPs1 -join ";`r`n" | Out-File -FilePath $bootPs1Path

& "$bootPs1Path" | Out-Null

Restart-Computer -Confirm:$false