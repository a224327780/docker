#!/bin/bash
GO_TTY_TAG_VER='v1.0.1'

apt-get update && apt-get install --no-install-recommends ca-certificates openssh-client procps zsh git vim wget curl net-tools -y
curl -sLk https://github.com/yudai/gotty/releases/download/${GO_TTY_TAG_VER}/gotty_linux_amd64.tar.gz | tar xzC /usr/local/bin

# zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
chsh -s $(which zsh)
echo 'alias ll="ls -la"' >>~/.zshrc
echo 'alias vi="vim"' >>~/.zshrc
echo 'export LANG=zh_CN.UTF-8' >>~/.zshrc
echo 'export LANGUAGE=zh_CN.UTF-8' >>~/.zshrc
echo 'export LC_ALL=zh_CN.UTF-8' >>~/.zshrc
echo 'export SHELL=/bin/zsh' >>~/.zshrc
echo 'export CLOUDFLARE_API_TOKEN=' >>~/.zshrc
echo 'export CLOUDFLARE_ACCOUNT_ID=0b1b69fc601a0a377396a70e7149bb12' >>~/.zshrc

echo "#!/bin/sh" >> /docker-entrypoint.sh
echo "set -e" >> /docker-entrypoint.sh
echo 'exec "$@"' >> /docker-entrypoint.sh

cat >/install.sh<<EOF
#!/bin/sh
  # curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
  apt-get install -y python3
  curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
  apt install -y python3-distutils && python3 get-pip.py && rm -f get-pip.py
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  # pnpm add -g wrangler
  # curl https://get.okteto.com -sSfL | sh
  # okteto context use https://cloud.okteto.com --token
  # okteto pipeline deploy --namespace=atmaming01 --name terminal --branch=terminal --repository=https://github.com/a224327780/okteto-apps --wait
  # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting
  # echo "source ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
EOF

apt-get autoremove -y && apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
chmod +x /docker-entrypoint.sh

git config --global user.name "a224327780"
git config --global user.email "a224327780@gmail.com"
git config --global pull.rebase false

source ~/.zshrc
