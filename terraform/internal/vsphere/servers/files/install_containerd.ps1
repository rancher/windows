$containerdService = Get-Service -Name containerd -ErrorAction "SilentlyContinue"
if ($containerdService.Status -eq 'Running') {
    Write-Host 'containerd is already installed.' -ForegroundColor Green
    exit 0
}

$containerdVersion = "1.7.12"
$nerdctlVersion = "1.7.2"
$crictlVersion = "v1.29.0"

$components = @{
    "containerd" = "https://github.com/containerd/containerd/releases/download/v$containerdVersion/containerd-$containerdVersion-windows-amd64.tar.gz"
    "nerdctl" = "https://github.com/containerd/nerdctl/releases/download/v$nerdctlVersion/nerdctl-$nerdctlVersion-windows-amd64.tar.gz"
    "crictl" = "https://github.com/kubernetes-sigs/cri-tools/releases/download/$crictlVersion/crictl-$crictlVersion-windows-amd64.tar.gz"
}

$components.GetEnumerator() | ForEach-Object {
    $component = $_.key
    $componentURL = $_.value

    Write-Host "Downloading $component from $componentURL..."
    Invoke-WebRequest -Uri $componentURL -OutFile "$env:TEMP\$component.tar.gz"

    New-Item "$env:TEMP\$component" -ItemType Directory -ErrorAction SilentlyContinue
    tar -x -f "$env:TEMP\$component.tar.gz" -C "$env:TEMP\$component"
}

$executables = @{
    "containerd" = "containerd\bin\containerd.exe"
    "ctr" = "containerd\bin\ctr.exe"
    "containerd-shim-runhcs-v1" = "containerd\bin\containerd-shim-runhcs-v1.exe"
    "containerd-stress" = "containerd\bin\containerd-stress.exe"
    "crictl" = "crictl\crictl.exe"
    "nerdctl" = "nerdctl\nerdctl.exe"
}
$executables.GetEnumerator() | ForEach-Object {
    $executable = $_.key
    $executablePath = $_.value

    Move-Item -Path (Join-Path $env:TEMP $executablePath) -Destination "$env:windir\System32\$executable.exe" -Force
}

Add-MpPreference -ExclusionProcess "$env:windir\System32\containerd.exe"

Write-Host "Starting containerd..."
& "$env:windir\System32\containerd.exe" --register-service
Start-Service containerd

New-Item "$env:ProgramData\crictl" -ItemType Directory -ErrorAction SilentlyContinue
@"
runtime-endpoint: npipe:////./pipe/containerd-containerd
image-endpoint: npipe:////./pipe/containerd-containerd
timeout: 2
"@ | Out-File "$env:ProgramData\crictl\crictl.yaml" -Encoding ascii
