FROM caoyufei/debian

COPY code-server/docker-entrypoint.sh /usr/bin/entrypoint.sh
COPY code-server/install.sh /tmp/install.sh

RUN chmod +x /tmp/install.sh && /bin/bash -c '/tmp/install.sh'

WORKDIR ~/workspace

CMD ["/usr/bin/entrypoint.sh"]