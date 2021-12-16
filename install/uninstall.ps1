Param (
[switch]$wsl,
[switch]$distrib
)

$isDone=$false

if ($distrib -or $wsl) {    
    wsl --unregister ubuntu-18.04-docker
    Write-Host "Distrib ubuntu-18.04-docker is now removed."    
    $isDone=$true
}

if ($wsl) {
    # This will restart the machine
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    $isDone=$true
}


if(-Not($isDone)) {
    Write-Host "Help:"
    Write-Host "Use option '-wsl' to uninstall wsl completely"
    Write-Host "Use option '-distrib' to only uninstall the dedicated docker distrib"
    Write-Host ""
    Exit -1
}