FROM ghcr.io/a224327780/debian

COPY terminal/install.sh /tmp/install.sh
COPY terminal/docker-entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /tmp/install.sh && /bin/bash -c '/tmp/install.sh'

CMD ["/usr/bin/entrypoint.sh"]