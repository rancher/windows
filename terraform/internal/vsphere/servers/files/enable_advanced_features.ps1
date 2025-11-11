$restart = $false

$requiredFeatures = @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform", "Microsoft-Hyper-V")
foreach ($feature in $requiredFeatures) {
    $state = $(Get-WindowsOptionalFeature -Online -FeatureName $feature).State
    if ($state -eq "Enabled") {
        Write-Host "$feature is installed." -ForegroundColor Green
        continue
    }
    $restart = $true
    Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
}
