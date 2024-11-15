FROM ghcr.io/a224327780/debian

ENV NGINX_VERSION=nginx-1.20.1 OPENSSL_VERSION=openssl-1.1.1k DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/usr/local/nginx/sbin WWW_ROOT=/data/wwwroot/default

ADD nginx/conf /tmp/conf

COPY nginx/docker-entrypoint.sh /docker-entrypoint.sh

RUN apt-get update -y \
    && apt-get --no-install-recommends install -y build-essential gcc g++ make wget openssl libssl-dev zlib1g zlib1g-dev libpcre3 libpcre3-dev \
    && CONFIG="\
    --prefix=/usr/local/nginx \
    --user=www \
    --group=www \
    --with-http_ssl_module \
    --with-http_sub_module \
    --with-http_gzip_static_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_v2_module \
    --with-http_stub_status_module \
    --with-openssl=/tmp/${OPENSSL_VERSION} \
    --with-openssl-opt='enable-weak-ssl-ciphers' \
    " \
    && groupadd www \
    && useradd -s /sbin/nologin -g www www \
    && cd /tmp \
    && wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate https://openssl.org/source/old/1.1.1/${OPENSSL_VERSION}.tar.gz \
    && tar zxf ${OPENSSL_VERSION}.tar.gz \
    && wget -nv https://nginx.org/download/${NGINX_VERSION}.tar.gz \
    && tar -zxf ${NGINX_VERSION}.tar.gz \
    && cd /tmp/${NGINX_VERSION} \
    && ./configure ${CONFIG} \
    && make \
    && make install \
    && strip /usr/local/nginx/sbin/nginx* \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx \
    && mkdir -p /data/nginx/vhost \
    && mkdir -p ${WWW_ROOT} \
    && mkdir -p /data/wwwlogs \
    && chown -R www:www /data \
    && chmod -R 777 /data/wwwlogs \
    && echo 'nginx version ${NGINX_VERSION}' > ${WWW_ROOT}/index.html \
    && echo '<?php\nphpinfo();' > ${WWW_ROOT}/index.php \
    && rm -f /usr/local/nginx/conf/nginx.conf \
    && cp -ra /tmp/conf/* /usr/local/nginx/conf/ \
    && apt-get purge wget make gcc g++ -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /docker-entrypoint.sh

WORKDIR /data/wwwroot
EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]