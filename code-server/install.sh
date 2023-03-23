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
echo 'export SHELL=/bin/zsh' >>~/.zshrc
echo 'export VSCODE_PROXY_URI=https://{{port}}.web02.eu.org' >>~/.zshrc
echo 'export CLOUDFLARE_API_TOKEN=' >>~/.zshrc
echo 'export CLOUDFLARE_ACCOUNT_ID=0b1b69fc601a0a377396a70e7149bb12' >>~/.zshrc

apt-get install -y python3 python3-distutils
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py

cat >/data/code-server/workspace/install.sh<<EOF
#!/bin/sh
  # curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
  apt-get install -y python3 python3-distutils
  curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  # pnpm add -g wrangler
  # curl https://get.okteto.com -sSfL | sh
  # okteto context use https://cloud.okteto.com --token
  # okteto pipeline deploy --namespace=atmaming01 --name terminal --branch=terminal --repository=https://github.com/a224327780/okteto-apps --wait
  # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting
  # echo "source ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
EOF

mkdir -p /data/code-server/{extensions,data,workspace}
# chown -R coder:coder /data/code-server 
apt-get autoremove -y && apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
chmod +x /usr/bin/entrypoint.sh /usr/bin/code-server

git config --global user.name "a224327780"
git config --global user.email "a224327780@gmail.com"
git config --global pull.rebase false

echo 'cd /data/code-server/workspace' >> ~/.zshrc
source ~/.zshrc