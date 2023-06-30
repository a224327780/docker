#!/bin/bash

apt-get update && apt-get install --no-install-recommends ca-certificates openssh-client procps zsh git unzip vim wget curl net-tools iputils-ping python3 python3-distutils -y

ARCH=$(dpkg --print-architecture)

CODE_RELEASE='4.14.1'

#CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||')
echo "${ARCH}-${CODE_RELEASE}"

curl -o /tmp/code-server.tar.gz -L "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${ARCH}.tar.gz"
tar zxf /tmp/code-server.tar.gz -C /usr/local/ 
ln -sf "/usr/local/code-server-${CODE_RELEASE}-linux-${ARCH}/bin/code-server" /usr/bin/code-server

# golang
curl -o /tmp/go-linux.tar.gz -L "https://go.dev/dl/go1.20.5.linux-${ARCH}.tar.gz"
tar zxf /tmp/go-linux.tar.gz -C /usr/local/
export PATH=$PATH:/usr/local/go/bin
go version

# zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
chsh -s $(which zsh)
export SHELL=$(which zsh)
echo "current shell: $SHELL\n"

wget --no-check-certificate -O /tmp/master.zip https://github.com/dracula/zsh/archive/master.zip
unzip /tmp/master.zip -d /tmp
ls -la /tmp
mv /tmp/zsh-master/dracula.zsh-theme ~/.oh-my-zsh/themes/
mv /tmp/zsh-master/lib/ ~/.oh-my-zsh/themes/

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="dracula"/g' ~/.zshrc 

echo 'alias ll="ls -la"' >> ~/.zshrc
echo 'alias vi="vim"' >> ~/.zshrc
echo 'export FLYCTL_INSTALL="/root/.fly"' >> ~/.zshrc
echo 'export PATH="$FLYCTL_INSTALL/bin:$PATH"' >> ~/.zshrc
echo 'export LANG=zh_CN.UTF-8' >> ~/.zshrc
echo 'export LANGUAGE=zh_CN.UTF-8' >> ~/.zshrc
echo 'export SHELL=/bin/zsh' >>~/.zshrc
echo 'export CLOUDFLARE_API_TOKEN=""' >>~/.zshrc
echo 'export CLOUDFLARE_ACCOUNT_ID=""' >>~/.zshrc
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
echo 'DRACULA_DISPLAY_CONTEXT=1' >>~/.zshrc
echo 'DRACULA_DISPLAY_FULL_CWD=1' >>~/.zshrc
echo 'DRACULA_DISPLAY_GIT=1' >>~/.zshrc
echo 'cd /data/code-server/workspace' >> ~/.zshrc

cat >~/.gitconfig<<EOF
[user]
        name = atcaoyufei
        email = atcaoyufei@gmail.com
[pull]
        rebase = false
EOF

bash <(curl -fsSL cli.new) -y
curl https://rclone.org/install.sh | bash
curl https://get.okteto.com -sSfL | sh
curl -L https://fly.io/install.sh | sh
curl -fsSL https://deno.land/x/install/install.sh | sh
curl -fsSL https://get.pnpm.io/install.sh | sh -
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py && rm -f get-pip.py

export PNPM_HOME="/root/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if command -v pnpm >/dev/null 2>&1; then
  pnpm env use 16 --global 
  pnpm add -g wrangler
  wrangler --version
fi

mkdir -p /data/code-server/{extensions,user-data,workspace} 
chmod +x /usr/bin/entrypoint.sh /usr/bin/code-server

cat >/data/code-server/workspace/NOTE.md<<EOF
curl https://get.acme.sh | sh -s email=atcaoyufei@gmail.com

okteto context use https://cloud.okteto.com --token
okteto pipeline deploy --namespace=atcooc123 --name code --branch=master --file okteto/code/docker-compose.yaml --repository=https://github.com/a224327780/paas --wait

flyctl launch --force-machines --image louislam/uptime-kuma:1 --name uptime001 --region hkg --internal-port 3001 --now

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo "source ${ZDOTDIR:-$HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
EOF

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*