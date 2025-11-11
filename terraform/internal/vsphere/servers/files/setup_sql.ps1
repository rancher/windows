# setup_sql.ps1 sets up a MS SQL 2022 instance. It does so by downloading the installer for the 2022 developer edition, using the installer to download the complete installation ISO
# and then extracting the ISO onto the disk. Once the setup media has been extracted, it uses PowerShell Declarative State Configuration to automate the installation and configuration
# of the SQL server via the 'setup.exe' binary.
function Write-Status {
    $now = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Write-Host -NoNewline "$now INFO: "
    Write-Host -ForegroundColor Gray ("=== {0} ===" -f ($args -join " "))
}

$domain = '${windows_AD_domain}'
$domainUserName ='${windows_AD_user}'
$domainPassword = '${windows_AD_password}'
$localPassword = '${local_password}'

if ($domainUserName -eq "") {
    Write-Host "Empty administrator username, cannot setup SQL server."
    exit 1
}

if ($domainPassword -eq "") {
    Write-Host "Empty administrator password, cannot setup SQL server."
    exit 1
}

Write-Status "Attempting to setup sql server"

New-NetFirewallRule -DisplayName 'sql-server-domain-tcp' `
                    -LocalPort 1433 -Action Allow `
                    -Profile 'Domain' `
                    -Protocol TCP `
                    -Direction Inbound

New-NetFirewallRule -DisplayName 'sql-server-private-tcp' `
                    -LocalPort 1433 -Action Allow `
                    -Profile 'Private' `
                    -Protocol TCP `
                    -Direction Inbound

Write-Status "Installing required Modules"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name SqlServerDsc -Force
Install-Module -Name SqlServer -Force
Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 9.1.0 -Force

$EXE_PATH = "C:\sql-installer"

# Create a working directory
Write-Status "Creating installation directory $EXE_PATH"

# Download the media installer
mkdir $EXE_PATH
cd $EXE_PATH
Write-Status "Downloading MS SQL 2022 Installer"
wget "https://go.microsoft.com/fwlink/p/?linkid=2215158&clcid=0x409&culture=en-us&country=us" -usebasicparsing -outfile setup.exe

# Download the ISO so we can install headless
Write-Status "Downloading installation ISO"
cmd.exe /c 'setup.exe /q /ACTION=Download /MEDIATYPE=iso /MEDIAPATH=C:\sql-installer'

Write-Status "Mounting and extracting ISO contents"
$isoPath = "C:\sql-installer\SQLServer2022-x64-ENU-Dev.iso"

# Extract the ISO onto the C:\ drive
$SQL_PATH = "C:\sql"
mkdir $SQL_PATH

Mount-DiskImage -ImagePath $isoPath
$drive = (Get-DiskImage -ImagePath $isoPath | Get-Volume).DriveLetter
Copy-Item -Path "$drive`:\*" -Destination $SQL_PATH -Force -Recurse
Dismount-DiskImage -ImagePath $isoPath

cd $SQL_PATH

# Start to create the DSC file
Write-Status "Creating DSC file"

# ref https://github.com/dsccommunity/SqlServerDsc/blob/main/source/Examples/Resources/SqlSetup/8-InstallDefaultInstanceSingleServer2022OrLater.ps1#L29
$conf = @"
Configuration SQLInstall
{
    param
    (
        [Parameter(Mandatory=`$true)]
        [System.Management.Automation.PSCredential]
        `$ServiceCredential,

        [Parameter(Mandatory=`$true)]
        [string]
        `$DomainAdminAccount,

        [Parameter(Mandatory=`$true)]
        [string]
        `$LocalAccount
    )

    Import-DscResource -ModuleName 'SqlServerDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node localhost
    {
        WindowsFeature 'NetFramework35'
        {
            Name   = 'NET-Framework-Core'
            Source = '\\fileserver.company.local\images$\Win2k12R2\Sources\Sxs'
            Ensure = 'Present'
        }

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }
        SqlSetup 'InstallDefaultInstance'
        {
            InstanceName        = 'MSSQLSERVER'
            Features            = 'SQLENGINE'
            SourcePath          = '$SQL_PATH'
            UpdateEnabled       = 'False'

            SQLSvcAccount       = `$ServiceCredential
            AgtSvcAccount       = `$ServiceCredential

            SQLSysAdminAccounts = `$DomainAdminAccount, 'BUILTIN\Administrators', 'NT AUTHORITY\SYSTEM', `$LocalAccount

            # Run the DSC resource itself as the provided user.
            PsDscRunAsCredential = `$ServiceCredential

            DependsOn            = '[WindowsFeature]NetFramework35', '[WindowsFeature]NetFramework45'
        }
    }
}
"@

Set-Content -Path installsql.ps1 -Value $conf

# source the DSC File
. .\installsql.ps1

# Setup a PS credential so the MS SQL service can run as the _local_ user.
$SqlSvcAcc = "administrator"
$password = ($localPassword | ConvertTo-SecureString -AsPlainText -Force)
$SqlSvcCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $SqlSvcAcc,$password

# add the domain user as an administrator
$domainAccount = $domain + "\" + $domainUserName

# Since this is a short lived dev environment, allow insecure passwords
$cd = @{
    AllNodes = @(
        @{
            NodeName                   = 'localhost'
            PSDscAllowPlainTextPassword= $true
            PSDscAllowDomainUser       = $true
        }
    )
}


# generate the mof file
Write-Status "Generating DSC MOF File"

SQLInstall -ServiceCredential $SqlSvcCred -DomainAdminAccount $domainAccount -LocalAccount $(whoami) -ConfigurationData $cd -OutputPath .

Write-Status "Executing DSC"
Start-DscConfiguration -Path "$SQL_PATH\SQLInstall" -Wait -Force -Verbose

Write-Status "Done Installing SQL Server"

