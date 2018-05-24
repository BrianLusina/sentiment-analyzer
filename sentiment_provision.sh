#!/usr/bin/env bash

# echo colors
CYAN='\033[0;36m'

echo -e "${CYAN} ===> Setting Timezone & Locale to $3 & en_US.UTF-8"

sudo ln -sf /usr/share/zoneinfo/$3 /etc/localtime
sudo apt-get install -qq language-pack-en
sudo locale-gen en_US
sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

echo -e "${CYAN} ===> Repair tty log message"
sudo sed -i "/tty/!s/mesg n/tty -s \\&\\& mesg n/" /root/.profile

# in order to avoid the message
# ===> default: dpkg-preconfigure: unable to re-open stdin: No such file or directory
# use "> /dev/null 2>&1 inorder to redirect stdout to /dev/null"
# for more info see http://stackoverflow.com/questions/10508843/what-is-dev-null-21

echo -e "${CYAN} ===>  Installing Node and NPM"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y npm

echo -e "${CYAN} ====> Installing yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
echo export PATH="$PATH:`yarn global bin`" >> ~/.bashrc

echo -e "${CYAN} ====>  Installing pip"
sudo apt-get install -y python3-pip
sudo apt-get install -y python-pip

echo "Installing virtualenv"
sudo pip install virtualenv

echo -e "${CYAN} ===>  Installing Git"
sudo apt-get -y install git
git config --global user.email 'lusinabrian@gmail.com'
git config --global user.name 'Brian Lusina'
git config --global credential.helper "cache --timeout=43200"

# JVM languages
echo -e "${CYAN} ===> Installing sdk man"
sudo apt-get install unzip
sudo apt-get install zip
curl -s get.sdkman.io | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo -e "${CYAN}====> Installing Gradle"
sdk install gradle

echo -e "${CYAN}====> Installing Kotlin"
sdk install kotlin

echo -e "${CYAN} ===>  Installing Java 8"
sdk install java

echo -e "${CYAN} ===>  Installing ZSH"
sudo apt-get -y install zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

echo -e "${CYAN}===> Installing and setting up Docker"
# allows docker to use the aufs storage drives
sudo apt-get install -y --no-install-recommends linux-image-extra-$(uname -r) linux-image-extra-virtual

# Install packages to allow apt to use a repository over HTTPS:
echo -e "${CYAN}===> Install pacckages to allow apt to use a repository over HTTPS"
sudo apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common

# add dockers official GPG key
echo -e "${CYAN}===> Adding Docker's official GPG key"
curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -

# verify the key id
echo -e "${CYAN}===> Verifying that key ID"
# apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
echo -e "${CYAN}====> Adding Docker to users"
sudo usermod -aG docker $(whoami)

# add stable repo
echo -e "${CYAN}===> Adding stable repository"
sudo add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"

# install docker
echo -e "${CYAN}===> Installing Docker"
sudo apt-get update
sudo apt-get -y install docker-engine

# test docker is working
echo -e "${CYAN}===> Testing Docker is working as expected"
sudo docker run hello-world

# Install Kubectl
echo -e "${CYAN} ====> Installing Kubectl"
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubectl

echo -e "${CYAN} ====> Installing Minikube"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.27.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

