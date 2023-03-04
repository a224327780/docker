FROM ghcr.io/a224327780/debian

COPY ./docker-entrypoint.sh /usr/bin/entrypoint.sh

RUN ARCH="$(dpkg --print-architecture)" \
    && apt-get update && apt-get install --no-install-recommends zsh vim wget curl wget -y \
    && VERSION=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
    && curl -fL https://github.com/coder/code-server/releases/download/v$VERSION/code-server-$VERSION-linux-${ARCH}.tar.gz | tar -C /usr/local/ -xz \
    && ln -s /usr/local/code-server-$VERSION/bin/code-server /usr/bin/code-server \
    && groupadd coder \
    && useradd -s /bin/zsh -g coder coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
    && echo "coder ALL=(ALL:ALL) ALL" >> /etc/sudoers \
    && mkdir -p /data/code-server/{extensions,data,workspace} \
    && chown -R coder:coder /data/code-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /usr/bin/entrypoint.sh

WORKDIR /data/code-server/workspace

CMD ["/usr/bin/entrypoint.sh"]