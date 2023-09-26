$name = "${name}"
$domainName = "${domain_name}"
$networkPrefixLength = "${network_prefix_length}"

Write-Output "Installing DNS Windows Feature..."

Install-WindowsFeature -Name DNS

Write-Output "Setting subnet mask prefix length to $networkPrefixLength"

Set-NetIPAddress -InterfaceAlias "Ethernet" -PrefixLength "$networkPrefixLength"

$active_directory_ip = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias "Ethernet").IPAddress

Write-Output "Setting DNS Client server address to static IP assigned to this host..."

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("$active_directory_ip")

$active_directory_ip_address_host_number = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias "Ethernet").IPAddress.split(".")[3]
$active_directory_ip_address_range = "$((Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias "Ethernet").IPAddress.split(".")[0,1,2] -join ".").0/24"
$active_directory_reverse_dns_zone = "$((Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias "Ethernet").IPAddress.split(".")[2,1,0] -join ".").in-addr.arpa"

try {
    Write-Output "Adding reverse DNS lookup zone $active_directory_reverse_dns_zone targeting IP Address range $active_directory_ip_address_range..."
    Add-DnsServerPrimaryZone -NetworkID "$active_directory_ip_address_range" -ReplicationScope "Domain"
} catch {
    Write-Output "Reverse DNS lookup zone $active_directory_reverse_dns_zone already exists."
}

try {
    Write-Output "Creating PTR record for in zone $active_directory_reverse_dns_zone named $active_directory_ip_address_host_number for the domain name $domainName..."
    Add-DnsServerResourceRecordPtr -Name "$active_directory_ip_address_host_number" -ZoneName "$active_directory_reverse_dns_zone" -PtrDomainName "$name.$domainName"
} catch {
    Write-Output "PTR record in zone $active_directory_reverse_dns_zone named $active_directory_ip already exists."
}

