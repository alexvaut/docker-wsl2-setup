if (-Not (Test-Path -Path .\__install)) { $dir = mkdir .\__install }

curl.exe -L -o .\__install\install.zip "https://raw.githubusercontent.com/alexvaut/docker-wsl2-setup/main/install.zip"

Expand-Archive -Force __install\install.zip .\__install

.\__install\install\install.ps1

Move-Item -Force .\__install\install\start-dockerd.ps1 .\start-dockerd.ps1
Move-Item -Force  .\__install\install\uninstall.ps1 .\uninstall.ps1

Start-Sleep -Seconds 1

Remove-Item -r .\__install -ErrorAction Ignore