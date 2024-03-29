FROM ghcr.io/a224327780/debian

ENV PHP_VERSION=php-7.3.29 PHPRedis_Ver=redis-5.3.4 Freetype_New_Ver=freetype-2.10.1 DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/usr/local/php/bin:/usr/local/php/sbin

ADD php/conf /tmp/conf
COPY php/docker-entrypoint.sh /docker-entrypoint.sh

ENV PHPIZE_DEPS autoconf dpkg-dev file g++ gcc libc-dev make pkg-config re2c

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends $PHPIZE_DEPS wget curl ca-certificates libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev openssl libssl-dev libxslt-dev \
    && CONFIG="\
    --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --with-gd --with-openssl  --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --without-libzip --enable-soap --with-gettext --enable-opcache --with-xsl --with-pear --disable-fileinfo" \
    && cd /tmp \
    && wget -nv --no-check-certificate http://soft.vpser.net/lib/freetype/${Freetype_New_Ver}.tar.xz \
    && tar Jxf ${Freetype_New_Ver}.tar.xz \
    && cd /tmp/${Freetype_New_Ver} \
    && ./configure --prefix=/usr/local/freetype --enable-freetype-config\
    && make \
    && make install \
    && [ -d /usr/lib/pkgconfig ] && \cp /usr/local/freetype/lib/pkgconfig/freetype2.pc /usr/lib/pkgconfig/ \
    && echo '/usr/local/freetype/lib' > /etc/ld.so.conf.d/freetype.conf \
    && ldconfig \
    && ln -sf /usr/local/freetype/include/freetype2/* /usr/include/ \
    && groupadd www \
    && useradd -s /sbin/nologin -g www www \
    && cd /tmp \
    && wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate https://soft.vpser.net/web/php/${PHP_VERSION}.tar.bz2 \
    && tar xjf ${PHP_VERSION}.tar.bz2 \
    && cd /tmp/${PHP_VERSION} \
    && ./configure $CONFIG \
    && make -j "$(nproc)" \
    && make install \
    && find /usr/local/php/bin /usr/local/php/sbin/ -type f -executable -exec strip --strip-all '{}' + || true \
	&& make clean \
    && mkdir -p /usr/local/php/etc/ \
    && mkdir -p /usr/local/php/conf.d/ \
    && ls -la /usr/local/php/bin/ \
    && ln -sf /usr/local/php/bin/php /usr/bin/php \
    && ln -sf /usr/local/php/bin/phpize /usr/bin/phpize \
    && ln -sf /usr/local/php/bin/pear /usr/bin/pear \
    && ln -sf /usr/local/php/bin/pecl /usr/bin/pecl \
    && ln -sf /usr/local/php/sbin/php-fpm /usr/bin/php-fpm \
    && cp php.ini-production /usr/local/php/etc/php.ini \
    && mkdir -p /data/wwwroot/ \
    && mkdir -p /data/wwwlogs \
    && chown -R www:www /data/wwwroot \
    && sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini \
    && sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini \
    && sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini \
    && sed -i 's/;error_log = php_errors.log/error_log = \/data\/wwwlogs\/php_errors.log/g' /usr/local/php/etc/php.ini \
    && sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini \
    && sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini \
    && sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini \
    && sed -i 's/disable_functions =.*/disable_functions = passthru,system,chroot,chgrp,chown,shell_exec,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini \
    && pear config-set php_ini /usr/local/php/etc/php.ini \
    && pecl config-set php_ini /usr/local/php/etc/php.ini \
    && pecl update-channels \
    && cp /tmp/conf/php-fpm.conf /usr/local/php/etc/php-fpm.conf \
    && rm ~/.pearrc \
    && rm -f /usr/local/php/conf.d/* \
    && cp /tmp/conf/004-opcache.ini /usr/local/php/conf.d/004-opcache.ini \
    && cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm \
    && chmod +x /etc/init.d/php-fpm \
    && cd /tmp \
    && wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate http://pecl.php.net/get/${PHPRedis_Ver}.tgz \
    && tar zxf ${PHPRedis_Ver}.tgz \
    && cd /tmp/${PHPRedis_Ver} \
    && /usr/local/php/bin/phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make \
    && make install \
    && cp /tmp/conf/007-redis.ini /usr/local/php/conf.d/007-redis.ini \
    && install -m 755 /tmp/conf/fpm-configure /usr/local/bin/fpm-configure \
    && wget --prefer-family=IPv4 --no-check-certificate -T 120 -t3 https://getcomposer.org/download/1.10.10/composer.phar -O /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer --version && php --version \
    && apt-get purge --auto-remove binutils autoconf dpkg-dev g++ gcc libc-dev make pkg-config re2c wget curl -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /docker-entrypoint.sh

WORKDIR /data/wwwroot

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["php-fpm", "-F", "--fpm-config", "/usr/local/php/etc/php-fpm.conf"]