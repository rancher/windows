#  setup_sql_management_ui.ps1 sets up the MS SQL Management suite. This tool is very useful and without it there is no UI for
#  browsing the sql server. This step can take a considerable amount of time to complete (> 10 mins).
Write-Host "Installing SQL Server Management UI, the SQL server can still be used during this operation. This is will take a while."
cd C:\Users\Administrator\Desktop
Write-Host "Downloading instllation exe"
wget https://aka.ms/ssms/21/release/vs_SSMS.exe -usebasicparsing -outfile vs_SSMS.exe
Write-Host "Download complete, starting install"
./vs_SSMS.exe /layout C:\Users\Administrator\Desktop --passive --force
Write-Host "Installation complete"
