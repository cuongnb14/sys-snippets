#!/bin/bash

echo "Installing basic tools..."
sudo apt-get update -qq

sudo apt-get install -y byobu zsh vim
sudo apt-get install -y git

sudo apt-get install -y mosh

sudo apt-get install -y htop monit

USERS="prod"

echo "Adding users:"
# Add ssh-key
for user in $USERS; do
    echo "- Add ${user}"
    adduser --disabled-password --gecos "" ${user}
    mkdir /home/${user}/.ssh
    touch /home/${user}/.ssh/authorized_keys

    chown ${user}:${user} -R /home/${user}/.ssh
    chmod 755 /home/${user}/.ssh
    chmod 644 /home/${user}/.ssh/authorized_keys

    # add cuongtran ssh key
    cat >> /home/${user}/.ssh/authorized_keys<<'EOM'
# Cuong Tran
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDACHkvrU00GAAKvyZkmxaNWyp+DjN8YmK6qr38MBPQSzfPVR/AsIRhB7Vc/+yB3XnbnGIsib175CmjC3jtsdm1yZbXrGpBpE0BEArwQirLT9eLVC73C3SFkSZ2RpCIQbHD7EV8SYg6cYlk3SivtrjZdl9kbObstlvt68yr998oEdydA5K8Wql9xUHJPN6x8yYgGk33TGnlSr6qY32vcEpvwruRx9SKozHj+q45hwLNVVjtcH9cecMV+tVF3uXgoAl6f1j/QJZtmycsimmomh909AywlHNmsUuBd2VLt1M4qtWQTC21NSiBDduDCMRe6aQHShULdCuOAHHUILWqqSv5 tranhuucuong91@gmail.com
EOM

    # grant sudo
    cat >> /etc/sudoers<<EOM
${user}    ALL=(ALL:ALL) NOPASSWD:ALL
EOM

    chsh -s /bin/zsh ${user}
done

echo "rm apt cache to avoid 'Hash Sum mismatch'"
sudo rm -rf  /var/lib/apt/lists/*

echo "Installing Docker..."
wget -qO- https://get.docker.com/ | sh

echo "Add users to docker group:"
for user in $USERS; do
    echo "- Add $user to docker group"
    sudo usermod -a -G docker ${user}
done

echo "Installing docker-compose..."
COMPOSE_VERSION=1.9.0
sudo wget -q https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` \
    -O /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Create a Swap File"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'

echo "Set timezone"
timedatectl set-timezone Asia/Ho_Chi_Minh

echo "Change default editor"
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim 100
