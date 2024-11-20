FROM caoyufei/debian

ENV DEBIAN_FRONTEND=noninteractive PATH=$PATH:/usr/local/php/bin:/usr/local/php/sbin

COPY php/*.sh /tmp/

RUN chmod +x /tmp/install.sh && /bin/bash -c '/tmp/install.sh'

WORKDIR /data/wwwroot

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/usr/local/bin/docker-start.sh"]