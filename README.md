# docker-wsl2-setup
Full setup of docker on Windows/wsl2

This repo contains scripts to install/uninstall:
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/about)
- [docker daemon](https://github.com/moby/moby) in dedicated WSL ubuntu 18.04 distribution (upgraded to latest packages when deployed)
- [a docker daemon API proxy](https://github.com/alexvaut/windows2wsl-docker-proxy) to adapt windows style path to linux path (C:\test => /mnt/c/test) to mount volumes easily.
- [portainer](https://www.portainer.io/) to get a web UI on top of docker API.
- [docker client](https://github.com/moby/moby) and [docker-compose](https://github.com/docker/compose) on windows

# How-To install

## Prerequisities

1. Uninstall Docker Desktop

## In an admin powershell:

1. First, ensure that you are using an administrative shell.

2. Install with powershell.exe

With PowerShell, you must ensure Get-ExecutionPolicy is not Restricted. We suggest using Bypass to bypass the policy to get things installed or AllSigned for quite a bit more security.

Run Get-ExecutionPolicy. If it returns Restricted, then run Set-ExecutionPolicy AllSigned or Set-ExecutionPolicy Bypass -Scope Process.

Now run the following command:

````
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alexvaut/docker-wsl2-setup/main/start-install-docker.ps1'))
````

3.  Paste the copied text into your shell and press Enter.
4.  Wait few minutes for the command to complete. You might not to restart, in such a case, run again the same command after the restart.
5.  If you don't see any errors, you are ready to use docker. In a new powershell windows (for the environment variable to be accessible), type docker ps -a. Browse to http://localhost:9008 to access portainer.

# How-To uninstall

When installing the script, the uninstall script 'uninstall.ps1' is downloaded as well. Same as for the install procedure, run the script in an administrative powershell to uninstall WSL or the distrib.
If you lost this script, you can execute this command that will run from the script hosted on github:

````
curl.exe -L -o uninstall.ps1 "https://raw.githubusercontent.com/alexvaut/docker-wsl2-setup/main/install/uninstall.ps1"
./uninstall.ps1 -distrib 1 #to uninstall: the distrib, docker daemon, docker daemon proxy & portainer 
./uninstall.ps1 -wsl 1 #to uninstall: wsl and everything from option 'distrib'
````

# Usage

To login on any registry like docker hub, just use the command line ``docker login -u username``

# Versions


| Component  | Version |
| ------------- | ------------- |
| WSL2  | Latest version when deployed  |
| ubuntu 18.04 LTS  | Upgraded to latest packages when deployed  |
| docker daemon  | Latest version when deployed  |
| docker daemon API proxy  | v0.1  |
| portainer  | Latest version when deployed |
| docker client  | v20.10.9  |
| docker client  | v2.2.2  |

# Tests

- This has been tested on Windows 10.0.19043
- Integration with Visual Studio 2022 and docker-compose workflow is ok
- Integration with [Visual Studio Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers) is ok


# References

This work has been done with the help of several sources (that were copy/pasted and modified):
- https://github.com/kaisalmen/wsltooling
- https://www.pugetsystems.com/labs/hpc/Note-How-To-Copy-and-Rename-a-Microsoft-WSL-Linux-Distribution-1811/
- https://superuser.com/questions/1317883/completely-uninstall-the-subsystem-for-linux-on-win10/1337814
- https://github.com/djl197/docker-wsl/tree/add_certificates
