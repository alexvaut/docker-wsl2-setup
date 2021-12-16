Param (
[switch]$wsl,
[switch]$distrib
)

$isDone=$false

if ($distrib -or $wsl) {    
    wsl --unregister ubuntu-18.04-docker
    $path = [System.Environment]::GetFolderPath("Desktop")
    Remove-Item -ErrorAction Ignore "$path\start-dockerd.ps1"
    Write-Host "Distrib ubuntu-18.04-docker is now removed."    

    Remove-Item -ErrorAction Ignore "C:/bin/docker.exe"
    Remove-Item -ErrorAction Ignore "C:/bin/docker-compose.exe" 
    Write-Host "Docker client and docker-compose are now removed."    
    
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