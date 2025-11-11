# setup_networking.ps1 configures the VM to set the primary DNS server to itself. Active Directory
# tracks resources using DNS, so it needs to be the authoritative DNS server. This script maintains
# existing DNS entries already assigned, to ensure all computers on the local network are still accessible.
# This script also creates PTR records and reverse DNS zones, which are required to automatically maintain a
# mapping of IP addresses to hostnames.

function Wait-ForService {
    param (
        [String]
        $service
    )
    Write-Host "Waiting for $service to be running..."
    $timeout = 10
    $attempt = 0
    while($true) {
        if ($attempt -eq $timeout) {
            Write-Host "$service did not start in a reasonable time"
            exit 1
        }
        $svc = Get-Service -Name $service
        if ($svc.Status -eq "Running") {
            Write-Host "$service has transitioned to Running"
            return
        }
        Write-Host "$service is not yet running, waiting 5 seconds..."
        Start-Sleep 5
        $attempt++
    }
}

$name = "${name}"
$domainName = "${domain_name}"

$ips = get-netipaddress -addressfamily ipv4
$interfaceIndex = 0
foreach($ip in $ips) {
    if ($ip.InterfaceAlias -like "*Ethernet0 2*") {
        $interfaceIndex = $ip.InterfaceIndex
        break
    }
}

Wait-ForService "DNS"
Wait-ForService "Dnscache"

# TODO: Is this needed now that we don't do network peering?
#Write-Output "Setting subnet mask prefix length to $networkPrefixLength"
#Set-NetIPAddress -InterfaceIndex $interfaceIndex -PrefixLength "$networkPrefixLength"

$active_directory_ip = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceIndex $interfaceIndex).IPAddress

Write-Output "Setting Primary DNS server address to the IP address of this host..."
$curDNS = Get-DnsClientServerAddress -AddressFamily IPV4
$newDNS = @($active_directory_ip) + $curDNS.IPAddresses
Set-DnsClientServerAddress -Interfaceindex $interfaceIndex -ServerAddresses $newDNS

$active_directory_ip_address_host_number = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceIndex $interfaceIndex).IPAddress.split(".")[3]
$active_directory_ip_address_range = "$((Get-NetIPAddress -AddressFamily IPV4 -InterfaceIndex $interfaceIndex).IPAddress.split(".")[0,1,2] -join ".").0/24"
$active_directory_reverse_dns_zone = "$((Get-NetIPAddress -AddressFamily IPV4 -InterfaceIndex $interfaceIndex).IPAddress.split(".")[2,1,0] -join ".").in-addr.arpa"

try {
    # Reverse DNS lookup zones are needed so we can go from ip -> hostname. Other machines can't join the domain without this.
    Write-Output "Adding reverse DNS lookup zone $active_directory_reverse_dns_zone targeting IP Address range $active_directory_ip_address_range..."
    Add-DnsServerPrimaryZone -NetworkID "$active_directory_ip_address_range" -ReplicationScope "Domain"
} catch {
    Write-Output "Reverse DNS lookup zone $active_directory_reverse_dns_zone already exists."
}

try {
    # PTR records keep A records and reverse lookup zones in sync
    Write-Output "Creating PTR record in zone $active_directory_reverse_dns_zone named $active_directory_ip_address_host_number for the domain name $domainName..."
    Add-DnsServerResourceRecordPtr -Name "$active_directory_ip_address_host_number" -ZoneName "$active_directory_reverse_dns_zone" -PtrDomainName "$name.$domainName"
} catch {
    Write-Output "PTR record in zone $active_directory_reverse_dns_zone named $active_directory_ip already exists."
}

