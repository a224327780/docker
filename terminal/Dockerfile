FROM ghcr.io/a224327780/debian

COPY terminal/install.sh /tmp/install.sh
COPY terminal/docker-entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /tmp/install.sh && /bin/bash -c '/tmp/install.sh'

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/usr/local/bin/gotty", "--reconnect", "--permit-write"]