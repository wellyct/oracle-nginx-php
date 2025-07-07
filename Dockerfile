FROM oraclelinux:9

ARG release=19
ARG update=26

# Install PHP 8.3 and required extensions
RUN dnf -y update &&\
    dnf -y install oraclelinux-developer-release-el9 epel-release &&\
    dnf -y install oracle-instantclient-release-el9 &&\
    dnf -y install oracle-instantclient${release}.${update}-basic oracle-instantclient${release}.${update}-devel oracle-instantclient${release}.${update}-sqlplus &&\
    dnf module enable -y php:8.3 && dnf module enable -y nodejs:22 &&\
    dnf -y install nginx nodejs npm nano unzip &&\
    dnf -y install php-cli php-fpm php-common php-mbstring php-xml php-bcmath php-intl php-zip php-pdo php-pear php-xml php-devel php-sqlite3 php-mysqlnd php-pgsql php-opcache php-xdebug php-curl php-bz2 &&\
    dnf clean all &&\
    rm -rf /var/cache/dnf

ENV PATH=$PATH:/usr/lib/oracle/${release}.${update}/client64/bin

# Install PHP oci8 extension
RUN echo "/usr/lib/oracle/19.26/client64/lib" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig  &&\
    echo 'instantclient,/usr/lib/oracle/19.26/client64/lib' | pecl install oci8  &&\
    echo "extension=oci8.so" > /etc/php.d/20-oci8.ini &&\
    curl -sS https://getcomposer.org/installer | php  && mv composer.phar /usr/local/bin/composer &&\
    npm install -g npm@latest &&\
    mkdir /var/run/php-fpm && mkdir -p /etc/nginx/sites-enabled &&\
    ln -sf /etc/nginx/sites-availabe/default /etc/nginx/sites-enabled/default &&\
    ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && echo "Asia/Jakarta" > /etc/timezone

# Set working directory
WORKDIR /var/www/html

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/sites-availabe/default
COPY tnsnames.ora /usr/lib/oracle/19.26/client64/lib/network/admin/tnsnames.ora

# Expose port
EXPOSE 80

# Jalankan supervisord untuk menjalankan nginx dan php-fpm bersama-sama
CMD ["/bin/sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
