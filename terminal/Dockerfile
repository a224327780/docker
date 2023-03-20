FROM ghcr.io/a224327780/debian

COPY terminal/install.sh /tmp/install.sh

RUN chmod +x /tmp/install.sh && /bin/bash -c '/tmp/install.sh'

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/local/bin/gotty", "--permit-write", "--reconnect", "/bin/zsh"]