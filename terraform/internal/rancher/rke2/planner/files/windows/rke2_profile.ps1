@"
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";c:\var\lib\rancher\rke2\bin;c:\usr\local\bin",
    [EnvironmentVariableTarget]::Machine)
Set-Item -Path Env:\CRI_CONFIG_FILE -Value "C:\var\lib\rancher\rke2\agent\etc\crictl.yaml"
Set-Item -Path Env:\CONTAINER_RUNTIME_ENDPOINT -Value "npipe:////./pipe/containerd-containerd"
"@ | Out-File -FilePath "$PSHOME\Profile.ps1"