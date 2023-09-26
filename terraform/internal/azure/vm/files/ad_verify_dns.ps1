$domainName = "${domain_name}"

Resolve-DnsName "$domainName"
if (-not $?) {
    Write-Output "Computer cannot find Active Directory instance via DNS. Restarting this host..."
    Start-Process -NoNewWindow powershell.exe "Start-Sleep 3; Restart-Computer -Confirm:`$false;";
} else {
    Write-Output "Active Directory IP found from DNS query."
}
