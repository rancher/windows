Invoke-WebRequest -Uri "https://aka.ms/wsl-ubuntu-1804" -OutFile $env:TEMP\wsl.zip -UseBasicParsing
Expand-Archive $env:TEMP\wsl.zip "$env:windir\System32\wsl" -Force

Add-MpPreference -ExclusionProcess "$env:windir\System32\wsl\ubuntu1804.exe"
& "$env:windir\System32\wsl\ubuntu1804.exe" install --root
