Param (
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslName,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$wslInstallationPath,
[Parameter(Mandatory=$True)][ValidateNotNull()][string]$username
)

# create staging directory if it does not exists
if (-Not (Test-Path -Path .\staging)) { $dir = mkdir .\staging }

curl.exe -L -o .\staging\ubuntuLTS.appx https://aka.ms/wsl-ubuntu-1804

Move-Item .\staging\ubuntuLTS.appx .\staging\$wslName.zip
Expand-Archive .\staging\$wslName.zip .\staging\$wslName

if (-Not (Test-Path -Path $wslInstallationPath)) {
    mkdir $wslInstallationPath
}
wsl --import $wslName $wslInstallationPath .\staging\$wslName\install.tar.gz

Remove-Item .\staging\$wslName.zip
Remove-Item -r .\staging\$wslName\

Write-Host "Upgrading $wslName ..."

# Update the system
wsl -d $wslName -u root bash -ic "apt update; apt upgrade -y"

# create your user and add it to sudoers
#wsl -d $wslName -u root bash -ic "./scripts/config/system/createUser.sh $username ubuntu"

# ensure WSL Distro is restarted when first used with user account
#wsl -t $wslName


