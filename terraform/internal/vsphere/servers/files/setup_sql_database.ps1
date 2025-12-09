Write-Host "Setting up test database..."
# dba tools module allows us to make sql queries from powershell
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PowerShellGet -Force
Install-Module -Name "dbatools" -Force -Scope AllUsers -AllowClobber
Set-Dbatoolsinsecureconnection

$testDBName = '${test_database_name}'
$testTable = '${test_table_name}'

if ($testDBName -eq "" ) {
    Write-Host "Did not provide a test DB name"
    exit 1
}

if ($testTable -eq "" ) {
    Write-Host "Did not provide a test table name"
    exit 1
}

Write-Host "Creating '$testDBName' database"
# Create a test database and table
New-DbaDatabase -SqlInstance localhost\MSSQLSERVER -Name $testDBName

$cols = @( )
$cols += @{
    Name              = 'Id'
    Type              = 'varchar'
    MaxLength         = 36
    DefaultExpression = 'NEWID()'
}
$cols += @{
    Name          = 'Value'
    Type          = 'varchar'
    MaxLength     = 36
}

Write-Host "Creating '$testTable' table"
New-DbaDbTable -SqlInstance localhost\MSSQLSERVER -Database $testDBName -Name $testTable -ColumnMap $cols

Write-Host "Adding some data..."

$insertquery="
INSERT INTO [dbo].[$testTable]
           ([Id],[Value])
     VALUES
           ('1','TEST' )
GO
"

Invoke-SQLcmd -ServerInstance 'localhost' -query $insertquery -Database $testDBName -TrustServerCertificate

# Enable TCP IP so others can connect
Write-Host "Enabling TCP IP for SQL server"
$wmi = New-Object 'Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer' localhost
$tcp = $wmi.ServerInstances['MSSQLSERVER'].ServerProtocols['Tcp']
$tcp.IsEnabled = $true
$tcp.Alter()

Write-Host "Restarting service and waiting 30 seconds..."
Restart-Service -Name MSSQLSERVER -Force
Start-Sleep 30
