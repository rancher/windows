# Install scoop globally
$env:SCOOP="C:\ProgramData\Scoop"
$env:SCOOP_GLOBAL = "C:\ProgramData\Scoop"
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'Machine')
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

irm get.scoop.sh -outfile 'install.ps1'
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
