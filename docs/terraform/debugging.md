# Debugging Terraform Setups

## Linux Servers

## Windows

Get scheduled tasks registered by the provisioning scripts:

```powershell
Get-ScheduledTask -TaskPath \Rancher\Terraform\
```

Get a transcript of all the logs from prior script runs:

```powershell
Get-ChildItem C:\etc\rancher-dev\cluster | Select-Object -ExpandProperty Name | Select-String ".*\.log" | ForEach-Object { Get-Content C:\etc\rancher-dev\cluster\$_ }
```

Get all task successful event logs:

```powershell
Get-WinEvent -FilterXml @"
<QueryList>
<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
<Select Path="Microsoft-Windows-TaskScheduler/Operational">*[EventData [@Name='TaskSuccessEvent']]</Select>
</Query>
</QueryList>
"@
```
