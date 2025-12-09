$env:SCOOP='C:\Applications\Scoop'
$env:SCOOP_GLOBAL='C:\GlobalScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
