#!/bin/bash

apt-get update && apt-get install --no-install-recommends ca-certificates openssh-client procps zsh git vim wget curl net-tools iputils-ping python3 python3-distutils -y

ARCH=$(dpkg --print-architecture)

CODE_RELEASE='4.11.0'

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
echo 'export FLYCTL_INSTALL="/root/.fly"' >> ~/.zshrc
echo 'export PATH="$FLYCTL_INSTALL/bin:$PATH"' >> ~/.zshrc
echo 'export LANG=zh_CN.UTF-8' >> ~/.zshrc
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.zshrc
echo 'export LC_ALL=zh_CN.UTF-8' >> ~/.zshrc
echo 'export SHELL=/bin/zsh' >>~/.zshrc
echo 'export CLOUDFLARE_API_TOKEN=""' >>~/.zshrc
echo 'export CLOUDFLARE_ACCOUNT_ID=""' >>~/.zshrc
echo 'export CF_Token=""' >>~/.zshrc
echo 'export CF_Account_ID=""' >>~/.zshrc
echo "PROMPT='%F{cyan}%n%f@%F{green}%m:%F{yellow}%3~%f $(git_prompt_info)$ '" >> .oh-my-zsh/themes/robbyrussell.zsh-theme
source ~/.zshrc

cat >~/.gitconfig<<EOF
[user]
        name = a224327780
        email = a224327780@gmail.com
[pull]
        rebase = false
EOF

curl https://get.acme.sh | sh -s email=atcaoyufei@gmail.com
curl https://get.okteto.com -sSfL | sh
curl -L https://fly.io/install.sh | sh
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py
source ~/.zshrc

if command -v pnpm >/dev/null 2>&1; then
  pnpm env use 16 --global 
  pnpm add -g wrangler
fi

mkdir -p /data/code-server/{extensions,data,workspace}
apt-get autoremove -y && apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
chmod +x /usr/bin/entrypoint.sh /usr/bin/code-server

echo 'cd /data/code-server/workspace' >> ~/.zshrc
source ~/.zshrc

cat >/data/code-server/workspace/INSTALL.md<<EOF
curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
apt update && apt-get install -y python3 python3-distutils && curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use 16 --global && pnpm add -g wrangler
curl https://get.okteto.com -sSfL | sh
okteto context use https://cloud.okteto.com --token
okteto pipeline deploy --namespace=atmaming01 --name terminal --branch=terminal --repository=https://github.com/a224327780/okteto-apps --wait
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo "source ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
EOF