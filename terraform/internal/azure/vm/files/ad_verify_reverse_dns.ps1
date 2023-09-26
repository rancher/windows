$domainIP = "${domain_ip}"

Resolve-DnsName "$domainIP"
if (-not $?) {
    Write-Output "Computer cannot find Active Directory instance in reverse lookup zone. Restarting this host..."
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";
} else {
    Write-Output "Active Directory DNS found from DNS reverse lookup."
}
