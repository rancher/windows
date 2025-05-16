#  This tool is very useful and without it there is no UI for browsing the sql server. However, this must be done as
#  the last step in the process as it takes a considerable amount of time to complete (> 10 mins).
Write-Host "Installing SQL Server Management UI, the SQL server can still be used during this operation. This is will take a while."
cd ~
Write-Host "Downloading instllation exe"
wget "https://aka.ms/ssmsfullsetup" -usebasicparsing -outfile smss-install.exe
Write-Host "Download complete, starting install"
./smss-install.exe /passive
Write-Host "Installation complete"
