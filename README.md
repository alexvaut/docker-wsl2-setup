# docker-wsl2-setup
Full setup of docker on Windows/wsl2

This repo contains scripts to install/uninstall:
- [WSL2](https://docs.microsoft.com/en-us/windows/wsl/about)
- [docker daemon](https://github.com/moby/moby) in dedicated WSL ubuntu 18.04 distribution (upgraded to latest packages when deployed)
- [a docker daemon API proxy](https://github.com/alexvaut/windows2wsl-docker-proxy) to adapt windows style path to linux path (C:\test => /mnt/c/test) to mount volumes easily.
- [portainer](https://www.portainer.io/) to get a web UI on top of docker API.
- [docker client](https://github.com/moby/moby) and [docker-compose](https://github.com/docker/compose) on windows

What is does support:

- [x] Easy install/uninstall
- [x] Low overhead
- [x] WSL2 Integration and installation
- [x] Enabling BuiltKit
- [x] localhost port mapping
- [x] GUI (Portainer)
- [x] Bind/mount files from host to VM
- [x] Route from container back to linux host
- [x] Integration with VS Code (remote dev container, docker extension) and VS Entreprise/Professional tested
- [ ] Upgrade is not supported yet. Note that data and binaries are in the same WSL2 Distrib for now. When upgrade will be available, it will likely get rid of the distrib, hence all docker data will be gone (which might not be a bad thing considering all the internal data docker keeps that are hard to completely remove).

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
4.  Wait few minutes for the command to complete. You might have to restart if wsl is not already installed, in such a case, run again the same command after the restart.
5.  If you don't see any error, you are ready to use docker. In a new powershell window (for the environment variable to be accessible), type `docker ps -a` or `docker run --name hello -v C:\test:/test hello-world`. Browse to http://localhost:9008 to access portainer.

# How-To uninstall

When installing the script, the uninstall script 'uninstall.ps1' is downloaded as well. Same as for the install procedure, run the script in an administrative powershell to uninstall WSL or the distrib.
If you lost this script, you can execute this command that will run from the script hosted on github:

````
curl.exe -L -o uninstall.ps1 "https://raw.githubusercontent.com/alexvaut/docker-wsl2-setup/main/install/uninstall.ps1"
./uninstall.ps1 -distrib #to uninstall: the distrib, docker daemon, docker daemon proxy & portainer (AND ALL DATA: images, volumes, containers...)
./uninstall.ps1 -wsl     #to uninstall: wsl and everything from option 'distrib'. It will require a restart.
````

# Usage

To start docker daemon, right click on the desktop icon "start-dockerd.ps1". 

![image](https://user-images.githubusercontent.com/20702322/146447447-307286b1-338b-4367-9462-d443e7a4efc4.png)

To login on any registry like docker hub, just use the command line ``docker login -u username``

# Versions

| Component  | Version |
| ------------- | ------------- |
| WSL2  | Latest version when deployed  |
| ubuntu 18.04 LTS  | Upgraded to latest packages when deployed  |
| docker daemon  | 20.10.12  |
| docker daemon API proxy  | v0.1  |
| portainer  | 1.24.2 |
| docker client (windows) | 20.10.9  |
| docker compose (windows) | v2.2.2  |

# Tests

- This has been tested on Windows 10.0.19043
- Integration with Visual Studio 2022 and docker-compose workflow is ok
- Integration with [Visual Studio Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers) is ok

# Troubleshooting

- If something goes wrong, stop the distrib with ``wsl -t ubuntu-18.04-docker``. And start dockerd daemon (with the script on the desktop).
- The name of the wsl distribution is "ubuntu-18.04-docker"
- In the ubuntu distribution, the dockerd password is "dockerd" in case you need log in wsl ``wsl -d ubuntu-18.04-docker``.

# Credits

This work has been done with the help of several sources (that were copy/pasted and modified):
- https://github.com/kaisalmen/wsltooling
- https://www.pugetsystems.com/labs/hpc/Note-How-To-Copy-and-Rename-a-Microsoft-WSL-Linux-Distribution-1811/
- https://superuser.com/questions/1317883/completely-uninstall-the-subsystem-for-linux-on-win10/1337814
- https://github.com/djl197/docker-wsl/tree/add_certificates
