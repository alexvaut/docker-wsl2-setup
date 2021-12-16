$DOCKER_COMPOSE_VERSION="v2.2.2"
$DOCKER_CLI_VERSION="20.10.9"
$binDir="C:/bin"

$symbols = [PSCustomObject] @{    
    CHECKMARK = ([char]8730)
}

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Write-host "Script Directory $dir"
Push-Location $dir

if (-Not (Test-Path -Path .\staging)) { $no = mkdir .\staging }

#Check if WSL is installed since it requires a reboot
$out= wsl -l
$n= $out.Split("\n").Count

If ($n -gt 20) {
    Write-Host "Installing WSL..."
    ./scripts/installWSL.ps1
    Write-Host "WSL is not installed yet, a reboot is required."
    Pop-Location
    exit -1
}

Write-Host "WSL already installed $($symbols.CHECKMARK)"

$enc = [system.Text.Encoding]::UTF8
$out = (wsl -l -v | out-string)
$c =  $enc.GetBytes($out) | Where-Object { $_ -ne 0 }
$out = $enc.GetString($c).Replace("\s","").Replace("\n","").Replace(" ","")
$name = "ubuntu-18.04-docker"

if (-not("$out" -match "ubuntu.*2")) {
    Write-Host "Installing WSL 2..."
    ./scripts/installWSL2.ps1
    Write-Host "Installing WSL 2 $($symbols.CHECKMARK)"
 }
 else {
    Write-Host "WSL2 already installed $($symbols.CHECKMARK)"
 }

if (-not("$out" -like "*$name*")) {
    Write-Host "Installing $name..."
    ./scripts/installUbuntuLTS.ps1 $name $HOME/WSL-images-$name docker
    Write-Host "Installing $name $($symbols.CHECKMARK)"
 }
 else {
    Write-Host "$name already installed $($symbols.CHECKMARK)"
 }



 if (-Not (Test-Path -Path $binDir)) {
    mkdir $binDir
}

if (-Not (Test-Path -Path C:/bin/docker-compose.exe)) {    
    Write-Host "docker-compose $DOCKER_COMPOSE_VERSION installing ..."
    curl.exe -L -o C:/bin/docker-compose.exe "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-windows-x86_64.exe"
    Write-Host "docker-compose $DOCKER_COMPOSE_VERSION installed $($symbols.CHECKMARK)"
}
else {
    Write-Host "docker-compose already installed $($symbols.CHECKMARK)"
}

if (-Not (Test-Path -Path C:/bin/docker.exe)) {    
    Write-Host "docker cli $DOCKER_CLI_VERSION installing ..."
    curl.exe -L -o .\staging\docker.zip "https://download.docker.com/win/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.zip"
    Expand-Archive -Force .\staging\docker.zip .\staging\docker
    Move-Item .\staging\docker\docker\docker.exe C:/bin/docker.exe
    #Remove-Item -r .\staging\docker*
    Write-Host "docker cli $DOCKER_CLI_VERSION installed $($symbols.CHECKMARK)"
}
else {
    Write-Host "docker cli already installed $($symbols.CHECKMARK)"
}

#setup environment variables
$addPath = "C:\bin"
$regexAddPath = [regex]::Escape($addPath)
$paths = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
$arrPath = $paths -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
$newPaths = ($arrPath + $addPath) -join ';'
[Environment]::SetEnvironmentVariable("Path", $newPaths, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("DOCKER_HOST", "tcp://localhost:2376", [System.EnvironmentVariableTarget]::User)

Write-Host "dockerd installing ..."
$bashScriptPath= wsl wslpath ((Resolve-Path ./scripts/setup-docker.sh).Path).Replace("\","/")
wsl -d $name -e $bashScriptPath
Write-Host "dockerd installing $($symbols.CHECKMARK)"

Remove-Item -r .\staging

Write-Host ""
Write-Host ""
Write-Host "To run docker and docker-compose clients, start a new shell (so that all env var are setup)."
Write-Host "To test mounting of volumes with windows path: "
Write-Host "docker run --name hello -v C:\test:/test hello-world"
Write-Host "docker -v C:\test:/test hello-world"
Write-Host "docker inspect hello"
Write-Host ""
Write-Host "Portainer is available on http://localhost:9008"
Write-Host ""
Write-Host ""

Pop-Location