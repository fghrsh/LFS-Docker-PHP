FROM php:7-fpm-alpine


RUN apk add --no-cache --virtual .build-deps \
       autoconf \
       g++ \
       libtool \
       make \
    && apk add --no-cache\
       postgresql-dev \
       freetype-dev \
       libpng-dev \
       tzdata \
       unzip \
       imagemagick-dev \
       libintl \
       icu \
       icu-dev \
       libxml2-dev \
       gettext-dev \
       freetype-dev \
       libjpeg-turbo-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install gd pdo_mysql mysqli pgsql pdo_pgsql opcache zip xmlrpc exif bcmath intl zip soap iconv gettext sockets \
    && apk del .build-deps
RUN apk add --no-cache --virtual .build-deps \
       autoconf \
       g++ \
       libtool \
       make \
       pcre-dev \
    && pecl install redis \
    && pecl install imagick \
	&& docker-php-ext-enable redis imagick \
    && apk del .build-deps

# PHP Composer
ADD https://dl.laravel-china.org/composer.phar /usr/local/bin/composer
RUN chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org

RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache \

COPY ./php.ini /usr/local/etc/php/php.ini

CMD ["php-fpm"]