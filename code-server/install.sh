#!/bin/bash

apt-get update && apt-get install --no-install-recommends ca-certificates openssh-client zsh git vim wget curl net-tools -y 

ARCH=$(dpkg --print-architecture)

CODE_RELEASE='4.10.1'

#CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||')
echo "${ARCH}-${CODE_RELEASE}"

curl -o /tmp/code-server.tar.gz -L "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${ARCH}.tar.gz"
tar zxf /tmp/code-server.tar.gz -C /usr/local/ 
ln -sf "/usr/local/code-server-${CODE_RELEASE}-linux-${ARCH}/bin/code-server" /usr/bin/code-server

# zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
chsh -s $(which zsh)
echo 'alias ll="ls -la"' >> ~/.zshrc
echo 'alias vi="vim"' >> ~/.zshrc

echo 'export LANG=zh_CN.UTF-8' >> ~/.zshrc
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.zshrc
echo 'export LC_ALL=zh_CN.UTF-8' >> ~/.zshrc

mkdir -p /data/code-server/{extensions,data,workspace}
# chown -R coder:coder /data/code-server 
apt-get autoremove -y && apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
chmod +x /usr/bin/entrypoint.sh /usr/bin/code-server

echo 'cd /data/code-server/workspace' >> ~/.zshrc
source ~/.zshrc