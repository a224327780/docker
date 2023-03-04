FROM ghcr.io/a224327780/debian

ARG CODE_RELEASE
COPY code-server/docker-entrypoint.sh /usr/bin/entrypoint.sh

RUN ARCH="$(dpkg --print-architecture)" \
    && apt-get update && apt-get install --no-install-recommends zsh vim wget curl wget -y \
    && echo "**** install code-server ****" && \
      if [ -z ${CODE_RELEASE+x} ]; then \
        CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
          | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
      fi && \
    mkdir -p /data/code-server/{extensions,data,workspace} \
    && wget --no-check-certificate -O /tmp/code-server.tar.gz "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${ARCH}.tar.gz" \
    && tar xf /tmp/code-server.tar.gz -C /usr/local/ \
    && ln -s /usr/local/code-server-${CODE_RELEASE}/bin/code-server /usr/bin/code-server \
    && groupadd coder \
    && useradd -s /bin/zsh -g coder coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
    && echo "coder ALL=(ALL:ALL) ALL" >> /etc/sudoers \
    && chown -R coder:coder /data/code-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /usr/bin/entrypoint.sh

WORKDIR /data/code-server/workspace

CMD ["/usr/bin/entrypoint.sh"]