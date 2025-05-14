# Add AD users and roles to the test database, including the default GMSA
Write-Host "Creating user logins and accounts"

$testDBName = '${test_database_name}'

if ($testDBName -eq "") {
    Write-Host "Did not provide a test database name"
    exit 1
}

$logonAndUsers = @(
    [PSCustomObject]@{
        Logon = "ad\GMSA1$"
        Username = "defaultGmsa"
    }
    [PSCustomObject]@{
        Logon = "ad\User1"
        Username = "testUser"
    }
)

foreach($user in $logonAndUsers) {
    $u = $user.Username
    $l = $user.Logon
    Write-Host "Creating Logon for $l, assocating login with user $u, and settings read write permission to database $testDBName"
    $q = "
     CREATE LOGIN [$l] FROM WINDOWS;
     USE $testDBName;
     CREATE USER $u FOR LOGIN [$l];
     ALTER ROLE db_datareader ADD MEMBER $u;
     ALTER ROLE db_datawriter ADD MEMBER $u;
    "
    Invoke-SQLcmd -ServerInstance 'localhost' -query $q -TrustServerCertificate
}

Write-Host "Done setting up SQL Server!"
