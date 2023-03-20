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

echo "#!/bin/sh" >> /docker-entrypoint.sh
echo "set -e" >> /docker-entrypoint.sh
echo 'exec "$@"' >> /docker-entrypoint.sh
cat >/README.md<<EOF
- curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
- apt-get install -y python3 python3-dev
- curl -fsSL https://get.pnpm.io/install.sh | sh -
- git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting
- echo "source ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
EOF

apt-get autoremove -y && apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
chmod +x /docker-entrypoint.sh

source ~/.zshrc
