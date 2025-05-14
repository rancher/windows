# This script sets up MS SQL 2022. It does so by downloading the installer for the 2022 developer edition, using the installer to download the complete installation ISO
# and then extracting the ISO onto the disk. Once the setup media has been extracted, it uses PowerShell DSC to automate the installation and configuration
# of the SQL server via the 'setup.exe' binary.

$adminUser ='${windows_AD_user}'
$adminpassword = '${windows_AD_password}'
$domain = '${windows_AD_domain}'
$localAdminUser = "$env:computername\$adminuser"

if ($adminUser -eq "") {
    Write-Host "Empty administrator username, cannot setup SQL server."
    exit 1
}

if ($adminpassword -eq "") {
    Write-Host "Empty administrator password, cannot setup SQL server."
    exit 1
}

# Set the domain for the AD admin user
if ($domain -ne "")
{
    $adminUser = $domain + "\" + $adminUser
}

Write-Host "Attempting to setup sql server"

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

Write-Host "Installing required Modules"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name SqlServerDsc -Force
Install-Module -Name SqlServer -Force
Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 9.1.0 -Force

# Create a working directory
Write-Host "Creating installation directory C:\sql"
mkdir C:\sql

# Download the media installer
Write-Host "Downloading MS SQL 2022 Installer"
wget "https://go.microsoft.com/fwlink/p/?linkid=2215158&clcid=0x409&culture=en-us&country=us" -usebasicparsing -outfile setup.exe

# Download the ISO so we can install headless
Write-Host "Downloading installation ISO"
cmd.exe /c 'setup.exe /q /ACTION=Download /MEDIATYPE=iso /MEDIAPATH=C:\Users\adminuser'

Write-Host "Mounting and extracting ISO contents"
$isoPath = "C:\Users\adminuser\SQLServer2022-x64-ENU-Dev.iso"
$destinationPath = "C:\sql"

# Extract the ISO onto the C:\ drive
Mount-DiskImage -ImagePath $isoPath
$drive = (Get-DiskImage -ImagePath $isoPath | Get-Volume).DriveLetter
Copy-Item -Path "$drive`:\*" -Destination $destinationPath -Force -Recurse
Dismount-DiskImage -ImagePath $isoPath

cd C:\sql

# Start to create the DSC file
Write-Host "Creating DSC"

# ref https://github.com/dsccommunity/SqlServerDsc/blob/main/source/Examples/Resources/SqlSetup/8-InstallDefaultInstanceSingleServer2022OrLater.ps1#L29
$conf = @"
Configuration SQLInstall
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=`$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        `$SqlInstallCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        `$SqlAdministratorCredential = `$SqlInstallCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        `$SqlServerAdminName,

        [Parameter()]
        [String]
        `$LocalAccount,

        [Parameter(Mandatory=`$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        `$SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        `$SqlAgentServiceCredential = `$SqlServiceCredential
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration' -ModuleVersion '9.1.0'
    Import-DscResource -ModuleName 'SqlServerDsc'

    node localhost
    {
        WindowsFeature 'NetFramework35'
        {
            Name   = 'NET-Framework-Core'
            Source = '\\fileserver.company.local\images$\Win2k12R2\Sources\Sxs' # Assumes built-in Everyone has read permission to the share and path.
            Ensure = 'Present'
        }

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
        }

        SqlSetup 'InstallDefaultInstance'
        {
            InstanceName           = 'MSSQLSERVER'
            Features               = 'SQLENGINE'
            SQLCollation           = 'SQL_Latin1_General_CP1_CI_AS'
            SQLSvcAccount          = `$SqlAdministratorCredential
            AgtSvcAccount          = `$SqlAdministratorCredential
            ASSvcAccount           = `$SqlAdministratorCredential
            SQLSysAdminAccounts    = `$SqlServerAdminName, `$LocalAccount, 'NT AUTHORITY\SYSTEM'
            InstallSharedDir       = 'C:\Program Files\Microsoft SQL Server'
            InstallSharedWOWDir    = 'C:\Program Files (x86)\Microsoft SQL Server'
            InstanceDir            = 'C:\Program Files\Microsoft SQL Server'
            InstallSQLDataDir      = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBDir           = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLUserDBLogDir        = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBDir           = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLTempDBLogDir        = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
            SQLBackupDir           = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup'
            ASServerMode           = 'TABULAR'
            SourcePath             = 'C:\sql'
            UpdateEnabled          = 'False'
            ProductCoveredbySA     = 1
            ForceReboot            = 0
            SqlTempdbFileCount     = 4
            SqlTempdbFileSize      = 1024
            SqlTempdbFileGrowth    = 512
            SqlTempdbLogFileSize   = 128
            SqlTempdbLogFileGrowth = 64

            PsDscRunAsCredential = `$SqlInstallCredential

            DependsOn            = '[WindowsFeature]NetFramework35', '[WindowsFeature]NetFramework45'
        }
    }
}
"@

Set-Content -Path installsql.ps1 -Value $conf

# source the DSC File
. .\installsql.ps1

# Since this is a short lived dev environment, allow insecure passwords
$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

# Setup a PS credential so the MS SQL service can run as the local user
$SqlSvcAcc = $adminUser
$password = ($adminpassword | ConvertTo-SecureString -AsPlainText -Force)
$SqlSvcCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $sqlSvcAcc,$password

# generate the mof file
Write-Host "Generating DSC MOF File"
SQLInstall -SqlServerAdminName "$adminUser" -LocalAccount $localAdminUser -SqlInstallCredential $SqlSvcCred -SqlAdministratorCredential $SqlSvcCred -SqlServiceCredential $SqlSvcCred -SqlAgentServiceCredential $SqlSvcCred -ConfigurationData $cd

Write-Host "Executing DSC"
Start-DscConfiguration -Path C:\sql\SQLInstall -Wait -Force -Verbose

Write-Host "Done Installing SQL Server"


