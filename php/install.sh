#!/bin/bash

PHP_VERSION='php-7.4.33'
imagick_VERSION='imagick-3.7.0'
AMQP_VERSION='2.1.0'
RABBITMQ_VERSION='0.12.0'
PHPRedis_Ver='redis-5.3.4'
Freetype_New_Ver='freetype-2.10.1'
MONGODB_VERSION='mongodb-1.19.4'
xlswriter='1.5.8'
ImageMagick_VERSION='7.1.1-40'

DIR='/tmp'

mv /tmp/docker-*.sh /usr/local/bin
chmod +x /usr/local/bin/docker-*.sh

apt-get update -y
apt-get install -y --no-install-recommends build-essential gcc g++ make cmake autoconf automake file libc-dev pkg-config re2c wget git curl ca-certificates libxml2-dev libcurl4-openssl-dev libjpeg-dev libsqlite3-dev libonig-dev libsodium-dev libpng-dev openssl libssl-dev libxslt-dev

groupadd www
useradd -s /sbin/nologin -g www www

mkdir -p /data/wwwroot/
mkdir -p /data/wwwlogs
chown -R www:www /data/wwwroot

CONFIG="--prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --with-gd --with-openssl  --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --without-libzip --enable-soap --with-gettext --enable-opcache --with-xsl --with-pear --with-webp --with-sodium"

cd ${DIR}
git clone https://github.com/viest/php-ext-excel-export
wget -c --no-check-certificate https://www.php.net/distributions/${PHP_VERSION}.tar.gz
wget -c --no-check-certificate https://github.com/alanxz/rabbitmq-c/archive/refs/tags/v${RABBITMQ_VERSION}.tar.gz
wget -c --no-check-certificate https://pecl.php.net/get/amqp-${AMQP_VERSION}.tgz
wget -c --no-check-certificate https://pecl.php.net/get/${MONGODB_VERSION}.tgz
wget -c --no-check-certificate http://pecl.php.net/get/${PHPRedis_Ver}.tgz
wget -c --no-check-certificate https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${ImageMagick_VERSION}.tar.gz
wget -c --no-check-certificate https://pecl.php.net/get/${imagick_VERSION}.tgz
wget -c --no-check-certificate https://download.savannah.gnu.org/releases/freetype/${Freetype_New_Ver}.tar.xz

# Freetype
tar Jxf ${DIR}/${Freetype_New_Ver}.tar.xz
cd ${DIR}/${Freetype_New_Ver}
./configure --prefix=/usr/local/freetype --enable-freetype-config
make && make install

[ -d /usr/lib/pkgconfig ] &&cp /usr/local/freetype/lib/pkgconfig/freetype2.pc /usr/lib/pkgconfig/
echo '/usr/local/freetype/lib' > /etc/ld.so.conf.d/freetype.conf
ldconfig
ln -sf /usr/local/freetype/include/freetype2/* /usr/include/

echo -e "[+] Installing ${PHP_VERSION}\n"
tar zxf ${DIR}/${PHP_VERSION}.tar.gz

ls -la
pwd
cd ${DIR}/${PHP_VERSION}
./configure ${CONFIG}
make -j "$(nproc)"
make install
find /usr/local/php/bin /usr/local/php/sbin/ -type f -executable -exec strip --strip-all '{}' + || true
make clean

mkdir -p /usr/local/php/etc/
mkdir -p /usr/local/php/conf.d/
ls -la /usr/local/php/bin/
ln -sf /usr/local/php/bin/php /usr/bin/php
ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
ln -sf /usr/local/php/bin/pear /usr/bin/pear
ln -sf /usr/local/php/bin/pecl /usr/bin/pecl
ln -sf /usr/local/php/sbin/php-fpm /usr/bin/php-fpm
cp php.ini-production /usr/local/php/etc/php.ini

sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log =/data\/wwwlogs\/php_errors.log/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,system,chroot,chgrp,chown,shell_exec,ini_alter,ini_restore,dl,openlog,syslog,readlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini

pear config-set php_ini /usr/local/php/etc/php.ini
pecl update-channels

cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 1024
pm.process_idle_timeout = 10s
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

rm ~/.pearrc
rm -f /usr/local/php/conf.d/*

cat >/usr/local/php/conf.d/001-opcache.ini<<EOF
[Zend Opcache]
zend_extension="opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF

cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
 
# rabbitmq
tar zxf ${DIR}/v${RABBITMQ_VERSION}.tar.gz
cd ${DIR}/rabbitmq-c-${RABBITMQ_VERSION}
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/rabbitmq-c
cmake --build . --target install

# amqp
tar zxf ${DIR}/amqp-${AMQP_VERSION}.tgz
cd ${DIR}/amqp-${AMQP_VERSION}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-librabbitmq-dir=/usr/local/rabbitmq-c
make && make install
echo 'extension = "amqp.so"' > /usr/local/php/conf.d/002-amqp.ini

# mongodb
tar zxf ${DIR}/${MONGODB_VERSION}.tgz
cd ${DIR}/${MONGODB_VERSION}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
echo 'extension = "mongodb.so"' > /usr/local/php/conf.d/003-mongo.ini

# redis
tar zxf ${DIR}/${PHPRedis_Ver}.tgz
cd ${DIR}/${PHPRedis_Ver}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
echo 'extension = "redis.so"' > /usr/local/php/conf.d/004-redis.ini

# xlswriter
cd ${DIR}/php-ext-excel-export
git submodule update --init
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --enable-reader
make && make install
echo 'extension = "xlswriter.so"' > /usr/local/php/conf.d/005-xlswriter.ini

# ImageMagick
tar -zxf ${DIR}/${ImageMagick_VERSION}.tar.gz
cd ${DIR}/ImageMagick-${ImageMagick_VERSION}
./configure --prefix=/usr/local/imagemagick
make && make install

# imagick
tar zxf ${DIR}/${imagick_VERSION}.tgz
cd ${DIR}/${imagick_VERSION}
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
make && make install
echo 'extension = "imagick.so"' > /usr/local/php/conf.d/006-imagick.ini

# composer
wget --no-check-certificate https://getcomposer.org/download/1.10.18/composer.phar -O /usr/local/bin/composer
chmod +x /usr/local/bin/composer

apt-get purge --auto-remove build-essential gcc g++ make cmake autoconf automake libc-dev pkg-config re2c wget curl git -y
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
apt-get clean
find -type f -name '*.a' -delete
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

composer --version
php --version
php -m