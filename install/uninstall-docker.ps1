Param (
[Parameter(Mandatory=$False)][ValidateNotNull()][bool]$wsl,
[Parameter(Mandatory=$False)][ValidateNotNull()][bool]$distrib
)

if ($wsl) {
    # This will restart the machine
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    exit 0
}

if ($distrib) {    
    wsl --unregister ubuntu-18.04-docker
    Write-Host "Distrib ubuntu-18.04-docker is now removed."
    exit 0
}

Write-Host "Pass option '-wsl 1'to uninstall wsl completely, pass option '-distrib 1' to only uninstall the dedicated docker distrib"