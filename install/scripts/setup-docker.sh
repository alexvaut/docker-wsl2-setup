#!/bin/bash

# This is a work-in-progress! Please don't use it yet.
# 
#
# Copyright 2021 Jonathan Bowman. All documentation and code contained
# in this file may be freely shared in compliance with the
# Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
# and is provided "AS IS" without warranties or conditions of any kind.
#
# To use this script, first ask yourself if I can be trusted (I can't; this is
# a work-in-progress), then read the code below and make sure you feel good
# about it, then consider downloading and executing this code that comes with
# no warranties or claims of suitability.
#
# OUT="$(mktemp)"; wget -q -O - https://raw.githubusercontent.com/bowmanjd/docker-wsl/main/setup-docker.sh > $OUT; . $OUT


DOCKER_GID=36257

POWERSHELL="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
SUDO_DOCKERD="%docker ALL=(ALL)  NOPASSWD: /usr/bin/dockerd"

confirm () {
  printf "%sIs this OK [Y/n/q]:" "$1"
  read -r REPLY
  echo
  case "$REPLY" in
    q*|Q*) echo "Ending script now at user's request."
      exit 1 ;;
    n*|N*) echo "Skipping at user's request."
      return 1 ;;
    *) return 0 ;;
  esac
}

confedit () {
  section=$1
  key=$2
  value=$3
  filename="/etc/wsl.conf"
  tempconf=$(mktemp)

  cp -p "$filename" "$tempconf"

  # normalize line spacing
  CONF=$(sed '/^$/d' "$tempconf" | sed '2,$ s/^\[/\n\[/g')"\n\n"

  if printf "%s" "$CONF" | grep -qF "[$section]" ; then
    if printf "%s" "$CONF" | sed -n "/^\[$section\]$/,/^$/p" | grep -q "^$key" ; then
      CONF=$(printf "%s" "$CONF" | sed "/^\[$section\]$/,/^$/ s/^$key\s*=.\+/$key = $value/")"\n\n"
    else
      CONF=$(printf "%s" "$CONF" | sed "/^\[$section\]$/,/^$/ s/^$/$key = $value\n/")"\n\n"
    fi
  else
    CONF="${CONF}[$section]\n$key = $value\n\n"
  fi
  printf "%s" "$CONF" > "$tempconf" && mv "$tempconf" "$filename"
}

# If root, query for username
if [ "$USER" = "root" ]; then  
  USERNAME="dockerd"
  printf "Non-root username to use: $USERNAME"
  getent passwd | grep -q "^$USERNAME:" && unset NEW_USER || NEW_USER="true"
  SUDO=""
else
  USERNAME=$USER
  if ! groups "$USERNAME" | grep -qEw "sudo|wheel" ; then
    echo "Unfortunately, sudo is not configured correctly for user $USERNAME."
    echo "Please try switching to a sudo-enabled user, or correctly configuring"
    echo 'sudo with the command "visudo".'
  fi
  SUDO="sudo"
fi

# If DNS lookup fails, doctor resolv.conf
if ! nslookup -timeout=2 google.com > /dev/null ; then
  echo "DNS lookup failed. Package installation will fail."
  confirm "This script will now edit your resolv.conf. " || exit 1
  $SUDO unlink /etc/resolv.conf 
  echo "nameserver 1.1.1.1" | $SUDO tee /etc/resolv.conf
  printf "[network]\ngenerateResolvConf = false\n\n" | $SUDO tee -a /etc/wsl.conf
fi

# Get distro info so that ID=distro
source /etc/os-release

echo
echo "Packages will now be updated, old Docker packages will be removed,"
echo "and official Docker packages will be installed."

$SUDO apt-get upgrade -y
$SUDO apt-get remove -y docker docker-engine docker.io containerd runc
$SUDO apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg2 sudo passwd
$SUDO curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | $SUDO tee /etc/apt/sources.list.d/docker.list
$SUDO apt update
$SUDO apt install docker-ce docker-ce-cli containerd.io -y
     

if [ $NEW_USER ] ; then
  echo
  echo "Adding user $USERNAME"  
  $SUDO adduser "$USERNAME"
  if ! $SUDO getent shadow | grep -q "^$USERNAME:\$" ; then
    $SUDO passwd "$USERNAME"
  fi
fi


SUDO_GROUP="sudo"
if ! groups "$USERNAME" | grep -qw "$SUDO_GROUP" ; then
  echo
  echo "Adding $USERNAME to group $SUDO_GROUP now."  
  if command -v usermod > /dev/null 2>&1 ; then
    $SUDO usermod -aG "$SUDO_GROUP" "$USERNAME"
  else
    $SUDO addgroup "$USERNAME" "$SUDO_GROUP"
  fi  
fi

SUDOERS="%$SUDO_GROUP ALL=(ALL) ALL" 
NORMALIZED=$(echo "$SUDOERS" | sed 's/\s\+/\\s\\+/g')
if ! $SUDO sh -c 'EDITOR=cat visudo 2> /dev/null' | grep -q "^$NORMALIZED" ; then
  echo
  echo "Enabling sudo access for everyone in group $SUDO_GROUP."  
  echo "$SUDOERS" | $SUDO sh -c "EDITOR='tee -a' visudo 1>/dev/null"  
fi

CURRENT_DOCKER_GID=$(getent group | grep -Ew "^docker" | cut -d: -f3)
if [ "$DOCKER_GID" != "$CURRENT_DOCKER_GID" ] ; then
  if ! getent group | grep -qw "$DOCKER_GID" ; then    
    echo "Changing ID of docker group from $CURRENT_DOCKER_GID to $DOCKER_GID."
    $SUDO sed -i -e "s/^\(docker:x\):[^:]\+/\1:$DOCKER_GID/" /etc/group
  else    
    echo "Group ID $DOCKER_GID already exists. Cannot change ID of Docker group."    
  fi
fi

if ! groups "$USERNAME" | grep -qw "docker" ; then
  echo "Adding $USERNAME to group docker now."  
  if command -v usermod > /dev/null 2>&1 ; then
    $SUDO usermod -aG docker "$USERNAME"
  else
    $SUDO addgroup "$USERNAME" docker
  fi  
fi

NORMALIZED=$(echo "$SUDO_DOCKERD" | sed 's/\s\+/\\s\\+/g')
if ! $SUDO sh -c 'EDITOR=cat visudo 2> /dev/null' | grep -q "^$NORMALIZED"; then  
  echo "Enabling passwordless sudo access to launch dockerd for everyone in group docker."
  echo "$SUDO_DOCKERD" | $SUDO sh -c "EDITOR='tee -a' visudo 1>/dev/null"  
fi

USERID=$(id -u "$USERNAME")
DISTRO_REGISTRY=$($POWERSHELL "Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq $WSL_DISTRO_NAME | select -exp PSPath" | tr -d '\r\n')
DEFAULT_UID=$($POWERSHELL "Get-ItemProperty '$DISTRO_REGISTRY' -Name DefaultUid | select -exp DefaultUid" | tr -d '\r\n')
if [ "$USERID" != "$DEFAULT_UID" ] ; then  
  echo "Setting $USERNAME as default user for WSL distro $WSL_DISTRO_NAME."
  $POWERSHELL "Set-ItemProperty '$DISTRO_REGISTRY' -Name DefaultUid -Value $USERID"  
fi

mkdir -p /etc/docker
touch "/etc/docker/daemon.json"
DOCKERD_CONFIG='{ "features": { "buildkit": true }, "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"], "log-driver": "local"}'
echo
echo "A new /etc/docker/daemon.json will be created or overwritten with the below contents."
printf "%s" "$DOCKERD_CONFIG"
if [ -r "/etc/docker/daemon.json" ] ; then
  echo "This will replace the existing file, which currently contains:"
  cat "/etc/docker/daemon.json"
fi
printf "%s" "$DOCKERD_CONFIG" | $SUDO tee "/etc/docker/daemon.json"


curl -fSL https://github.com/alexvaut/windows2wsl-docker-proxy/releases/download/0.1/proxy-docker -o /home/dockerd/proxy-docker
chmod +x /home/dockerd/proxy-docker

HOMEDIR=$(getent passwd | grep -w "$USERNAME" | cut -d: -f6)
LAUNCHER_DIR="$HOMEDIR/.local/bin"
LAUNCHER="$LAUNCHER_DIR/docker-service.sh"
LAUNCHER_TEMP=$(mktemp)
printf "#!/bin/sh\n\nDOCKER_DISTRO='%s'\n" "$WSL_DISTRO_NAME" > "$LAUNCHER_TEMP"
cat <<-'EOF' >> "$LAUNCHER_TEMP"
/mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > /tmp/dockerd.log 2>&1"
/mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b /home/dockerd/proxy-docker -l :2376 -r localhost:2375 < /dev/null > /tmp/proxy-docker.log 2>&1"
EOF

echo
echo
echo "Adding $LAUNCHER startup script, with these contents:"
cat "$LAUNCHER_TEMP"

mkdir -p "$LAUNCHER_DIR"
mv -f "$LAUNCHER_TEMP" "$LAUNCHER"
chmod u=rwx,g=rx,o= "$LAUNCHER"
chgrp docker "$LAUNCHER"

echo "Starting dockerd..."
$LAUNCHER_DIR/docker-service.sh
until [ -r /var/run/docker.sock ] ; do
  echo "Waiting for dockerd to start..."
  sleep 1
done
echo "dockerd started"

echo "Installing portainer as a container ..."
docker volume create portainer_data
docker run -d -p 9008:9000 --name portainer --restart=always -v portainer_data:/data --add-host=host.docker.internal:host-gateway portainer/portainer -H tcp://host.docker.internal:2375
echo "Installing portainer as a container done."
