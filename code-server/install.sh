#!/bin/bash

apt-get update && apt-get install --no-install-recommends zsh vim wget curl wget -y 

ARCH=$(dpkg --print-architecture)

function get_latest_release() {
  curl --silent "https://api.github.com/repos/coder/code-server/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# CODE_RELEASE=$(get_latest_release)
CODE_RELEASE='4.10.1'

#CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||')
echo "${ARCH}-${CODE_RELEASE}"

wget --no-check-certificate -O /tmp/code-server.tar.gz "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${ARCH}.tar.gz"
tar xf /tmp/code-server.tar.gz -C /usr/local/ 
ln -s /usr/local/code-server-${CODE_RELEASE}/bin/code-server /usr/bin/code-server 
# groupadd coder 
# useradd -s /bin/zsh -g coder coder 
# echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
# echo "coder ALL=(ALL:ALL) ALL" >> /etc/sudoers

# nvm node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
nvm install 16

# python
curl https://pyenv.run | bash
pyenv install 3.8

# zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
chsh -s $(which zsh)

mkdir -p /data/code-server/{extensions,data,workspace}  
# chown -R coder:coder /data/code-server 
apt-get clean 
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
chmod +x /usr/bin/entrypoint.sh