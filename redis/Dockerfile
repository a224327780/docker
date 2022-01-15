FROM ghcr.io/a224327780/debian

ENV Redis_Stable_Ver=redis-6.2.6 DEBIAN_FRONTEND=noninteractive REDIS_PSSWORD=a224327780
ENV PATH=$PATH:/usr/local/redis/bin

COPY redis/docker-entrypoint.sh /docker-entrypoint.sh

RUN apt-get update -y \
    && apt-get --no-install-recommends install -y build-essential gcc make wget libc6-dev ca-certificates \
    && groupadd redis \
    && useradd -s /sbin/nologin -g redis redis \
    && cd /tmp \
    && wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate http://download.redis.io/releases/${Redis_Stable_Ver}.tar.gz \
    && tar zxf ${Redis_Stable_Ver}.tar.gz \
    && cd ${Redis_Stable_Ver} \
    && make PREFIX=/usr/local/redis install \
    && mkdir -p /usr/local/redis/etc/ && mkdir -p /data/redis \
    && chown -R redis:redis /data/redis \
    && cp redis.conf  /usr/local/redis/etc/ \
    && sed -i 's#^dir.*#dir \/data\/redis#g' /usr/local/redis/etc/redis.conf \
    && sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/g' /usr/local/redis/etc/redis.conf \
    && apt-get purge build-essential gcc make wget libc6-dev ca-certificates -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /docker-entrypoint.sh

WORKDIR /data/redis

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 6379
CMD ["redis-server", "/usr/local/redis/etc/redis.conf", "--requirepass \"${REDIS_PSSWORD}\""]