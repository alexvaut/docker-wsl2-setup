if (-Not (Test-Path -Path .\__install)) { $dir = mkdir .\__install }

curl.exe -L -o .\__install\install.zip "https://raw.githubusercontent.com/alexvaut/docker-wsl2-setup/main/install.zip"

Expand-Archive __install\install.zip .\__install

.\__install\install\install.ps1

Move-Item -Force .\__install\install\start-dockerd.ps1 .\start-dockerd.ps1
Move-Item -Force  .\__install\install\uninstall-docker.ps1 .\uninstall.ps1

Start-Sleep -Seconds 1

try { Remove-Item -r .\__install }
catch { 
    # do nothing
}