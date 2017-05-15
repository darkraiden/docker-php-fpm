FROM centos:7

ENV SHELL /bin/bash
ENV PHP_REPO http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
ENV PHP_COMPOSER true
ENV PHP_OWNER nginx
ENV PHP_GROUP nginx
ENV PHP_MAX_CHILDREN 50
ENV PHP_MEMORY_LIMIT 128
ENV PHP_PACKAGES \
                 php-fpm \
                 php-cli \
                 php-xml \
                 php-libxml \
                 php-intl \
                 php-pecl-oauth \
                 php-bcmath \
                 php-gmp \
                 php-gd \
                 php-soap \
                 php-openssl \
                 php-mysql \
                 php-mbstring \
                 php-tokenizer \
                 php-mcrypt \
                 php-bitset \
                 php-pecl-amqp \
                 php-pgsql

#Add nginx user
RUN groupadd nginx &&\
	adduser -s /sbin/nologin -g nginx nginx
#Install base image deps
RUN yum install -y wget

#Install the REMI repo
RUN yum -y install $PHP_REPO

#Install php-fpm and any required packages
RUN yum --enablerepo=remi,remi-php71 install -y $PHP_PACKAGES &&\
    yum clean all &&\
    php -v

#Copy www.conf file to container
COPY ./www.conf /etc/php-fpm.d/www.conf

#Install Composer, if PHP_COMPOSER == true
RUN if $PHP_COMPOSER; then \
        wget https://getcomposer.org/download/1.2.4/composer.phar &&\
        mv composer.phar /var/lib/composer &&\
        chmod +x /var/lib/composer &&\
        ln -s /var/lib/composer /usr/local/bin/composer; \
    fi

COPY docker-php-entrypoint /usr/local/bin

ENTRYPOINT ["docker-php-entrypoint"]

EXPOSE 9000

CMD ["php-fpm", "-FO"]
