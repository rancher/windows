# add_scheduled_tasks.ps1
#
# This script ensures that all the scripts passed in to boot up this machine are run sequentially utilizing the Windows Task Scheduler.

$taskPath = "\Rancher\Terraform\"
$scriptDir = "C:\etc\rancher-dev\cluster"

# Don't do anything if there's nothing to do
$scripts = @(${scripts})
if ($scripts.Count -eq 0)
{
    Write-Output "No scripts to execute."
    exit 0
}

# Create a script directory
Remove-Item $scriptDir -Recurse -Force -ErrorAction SilentlyContinue;
New-Item -ItemType Directory -Force -Path "$scriptDir";

# Start putting logs from this script into that directory
Start-Transcript -Path "$scriptDir\add_scheduled_tasks.ps1.log"

# Turn on Windows Task Scheduler event logs. This allows previous tasks to trigger the next tasks automatically on successful completion
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true

# Remove all stale tasks from previous runs on this extension
Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

# Register an entrypoint.ps1 task that will be triggered at the end of this script manually
$entryTaskName = "entrypoint.ps1"
$taskName = $entryTaskName
$ps1Path = Join-Path -Path $scriptDir $taskName
@"
`$taskPath="$taskPath"
`$scripts = @(${scripts})
for (`$i=0; `$i -lt `$scripts.Length; `$i++) {
    `$taskName = `$scripts[`$i]
    `$firstTask = Get-ScheduledTask -TaskName `$taskName -TaskPath `$taskPath -ErrorAction SilentlyContinue
    if (`$?) {
        `$firstTask | Start-ScheduledTask
        break
    }
}
"@ | Out-File -FilePath $ps1Path

$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -NoLogo -NoProfile -ExecutionPolicy Bypass $ps1Path"
# This task also automatically triggers on a reboot performed **at the end** of a user provided script, which will prevent the next task from starting
# since the event is missed by the TaskScheduler on a reboot.
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -User System -TaskName $taskName -TaskPath $taskPath -Action $taskAction -Trigger $taskTrigger

# Register individual scripts provided
for ($i=0; $i -lt $scripts.Length; $i++) {
    $taskName = $scripts[$i]
    $ps1Script = @(
        "Start-Transcript -Path `"$scriptDir\$taskName.log`"",
        "Write-Output `"Sleeping for 3 seconds`"",
        "Start-Sleep -Seconds 3",
        "Write-Output `"Executing script...`""
    )
    $destinationPath = Join-Path -Path "C:\\scripts" $scripts[$i]
    $ps1Script += "Write-Output `"Executing $destinationPath...`""
    $ps1Script += "& `"$destinationPath`""

    $ps1Script += "Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:`$false -ErrorAction SilentlyContinue;"

    $ps1Path = Join-Path -Path $scriptDir "entrypoint-$taskName"
    $ps1Script -join ";`r`n" | Out-File -FilePath $ps1Path

    $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -NoLogo -NoProfile -ExecutionPolicy Bypass $ps1Path"

    if ($i -eq 0)
    {
       Register-ScheduledTask -User System -TaskName $taskName -TaskPath $taskPath -Action $taskAction
    }
    else
    {
        $taskSchedulerEventTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
        $taskTrigger = New-CimInstance -CimClass $taskSchedulerEventTriggerClass -ClientOnly
        # Note: The below subscription is the "magic" that allows successful runs of prior tasks to trigger the next task to start automatically
        $taskTrigger.Subscription = 
@"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">*[EventData [@Name='TaskSuccessEvent'][Data[@Name='TaskName']='{0}{1}']]</Select>
</Query>
</QueryList>
"@ -f @("$taskPath", "$previousTaskName")
        $taskTrigger.Enabled = $True 
        Register-ScheduledTask -User System -TaskName $taskName -TaskPath $taskPath -Action $taskAction -Trigger $taskTrigger
    }

    $previousTaskName = $taskName
}

# Trigger the entrypoint
Start-ScheduledTask -TaskName "$entryTaskName" -TaskPath "$taskPath"
