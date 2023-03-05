#!/bin/bash

apt-get update && apt-get install --no-install-recommends ca-certificates openssh-client zsh git vim wget curl net-tools -y 

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
cd /tmp

curl -o /tmp/code-server.tar.gz -L "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${ARCH}.tar.gz"
tar zxf /tmp/code-server.tar.gz -C /usr/local/ 
ln -sf "/usr/local/code-server-${CODE_RELEASE}-linux-${ARCH}/bin/code-server" /usr/bin/code-server 

# groupadd coder 
# useradd -s /bin/zsh -g coder coder 
# echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
# echo "coder ALL=(ALL:ALL) ALL" >> /etc/sudoers

# zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
chsh -s $(which zsh)
echo 'alias ll=ls -la' >> ~/.zshrc
echo 'alias vim=vim' >> ~/.zshrc
echo 'cd /data/code-server/workspace' >> ~/.zshrc

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# nvm node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | zsh
nvm install 16
node --version

# python
curl https://pyenv.run | zsh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

mkdir -p /data/code-server/{extensions,data,workspace}
# chown -R coder:coder /data/code-server 
apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
chmod +x /usr/bin/entrypoint.sh /usr/bin/code-server