# setup_active_directory.ps1 creates active directory users, groups, and gMSA's.

$ProgressPreference = "SilentlyContinue"

Write-Output "Registering this computer as an Active Directory Domain Controller..."
while ($true) {
    try {
        $domain = Get-ADDomain
    }
    catch {
        Write-Output "Waiting for Active Directory domain to be set up..."
        Start-Sleep 3
        continue
    }
    break
}

# Required to create gMSAs
try {
    Get-AdsRootKey
}
catch {
    Add-KdsRootKey -EffectiveTime (Get-Date).AddHours(-10) | Out-Null
}

$defaultPassword = "${password}"

$rancherAccount = "${rancher_account}"
$rancherGroup = $rancherAccount + "Group"

$gmsaImpersonationAccount = "${gmsa_impersonation_account}"
$gmsaImpersonationGroup = $gmsaImpersonationAccount + "Group"

$standardUsers = Convertfrom-Json @"
${jsonencode(standard_users)}
"@

$gmsas = Convertfrom-Json @"
${jsonencode(gmsas)}
"@

$domainDns = $domain | Select -ExpandProperty DnsRoot

function Init-ADUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Name,

        [Parameter(Mandatory)]
        $Password
    )

    $accountPassword = ConvertTo-SecureString -AsPlainText $Password -Force

    try {
        Get-AdUser $Name | Set-AdAccountPassword -Reset -NewPassword $accountPassword
        Write-Output "$Name (unchanged)"
    }
    catch {
        New-ADUser -Name $Name -AccountPassword $accountPassword -Enabled 1 | Out-Null
        Write-Output "$Name (created)"
    }
}

function Init-ADGMSAs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$GMSAs,

        [Parameter(Mandatory)]
        $ImpersonationGroup
    )

    # Create an impersonation account that CCG can use 
    # This impersonation account will be placed into a group that has permissions to retrieve the managed passwords of gMSAs
    Init-ADUser -Name $gmsaImpersonationAccount -Password $defaultPassword
    Init-ADGroup -Name $gmsaImpersonationGroup -Members $gmsaImpersonationAccount
    # Create or confirm
    foreach ($GMSA in $GMSAs) {
        try { 
            Get-AdServiceAccount $GMSA
            Write-Output "$GMSA (unchanged)"
        }
        catch {
            New-ADServiceAccount -Name $GMSA -DnsHostName "$GMSA.$domainDns" -ServicePrincipalNames "host/$GMSA", "host/$GMSA.$domainDns" | Out-Null
            Write-Output "$GMSA (created)"
        }
        Set-AdServiceAccount -Identity $GMSA -PrincipalsAllowedToRetrieveManagedPassword @($ImpersonationGroup, "Domain Controllers", "Domain Computers")
    }

    # Cleanup
    $existingGMSAs = Get-AdServiceAccount -Filter '*' | Select -ExpandProperty Name

    foreach ($GMSA in $existingGMSAs) {
        if ($GMSAs -contains $GMSA) {
            continue
        }
        Remove-ADServiceAccount $GMSA -Confirm:$false | Out-Null
        Write-Output "$GMSA (removed)"
    }
}

function Init-ADGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Name,
        
        [Parameter()]
        [string[]]$Members
    )

    try {
        Get-AdGroup $Name
        Write-Output "$Name (unchanged)"
    }
    catch {
        New-ADGroup -Name $Name -SamAccountName $Name -GroupScope DomainLocal | Out-Null
        Write-Output "$Name (created)"
    }

    $groupMembers = Get-ADGroupMember -Identity $Name -Recursive | Select -ExpandProperty Name

    foreach ($Member in $Members) {
        if ( $groupMembers -contains "$Member" ) {
            continue
        }
        Add-ADGroupMember -Identity $Name -Members $Member | Out-Null
        Write-Output "$Member (added to $Name)"
    }

    foreach ($Member in $groupMembers) {
        if ( $Members -contains "$Member" ) {
            continue
        }
        Remove-ADGroupMember -Identity $Name -Members $Member -Confirm:$false | Out-Null
        Remove-ADUser $Member -Confirm:$false | Out-Null
        Write-Output "$Member (removed)"
    }
}

function Init-AD {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$StandardUsers,

        [Parameter(Mandatory)]
        [bool]$Rancher,
        
        [Parameter()]
        [string[]]$GMSAs
    )

    # Standard Users
    # Intended to be used to directly log in
    foreach ($User in $StandardUsers) {
        Init-ADUser -Name $User.Name -Password $User.Password
    }
    Init-ADGroup -Name "StandardUsers" -Members ($StandardUsers | ForEach-Object { $_.Name })

    # Rancher Support
    # Create an impersonation account that Rancher can use that has permissions to perform LDAP searches and read attributes of groups and users in the domain
    # Used as Rancher's "service account" in the local cluster
    switch ($Rancher) {
        $true {
            Init-ADUser -Name $rancherAccount -Password $defaultPassword
            Init-ADGroup -Name $rancherGroup -Members $rancherAccount
        }
    }

    # GMSA Support
    Init-ADGMSAs -GMSAs $GMSAs -ImpersonationGroup $gmsaImpersonationGroup
}

# entrypoint
Init-AD -StandardUsers $standardUsers -Rancher $true -GMSAs $gmsas
