FROM ubuntu:18.04

MAINTAINER Jakub Szczygłowski <jszczyglowski@gmail.com>

WORKDIR /var/www/

# Deploy Apache and PHP

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 \
		libapache2-mod-php \
		php-cli \
		php-curl \
		php-mbstring \
		php-json \
		php-gd \
		php-pgsql \
		php-xml \
		php-opcache \
		php-fpm \
		postgresql-client \
		curl \
		sudo \
		git \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Deploy TT-RSS

RUN git clone https://tt-rss.org/git/tt-rss.git tt-rss \
	&& chown www-data:www-data -R /var/www/tt-rss

# Expose and run

EXPOSE 80

COPY ttrss-entrypoint.sh /var/www/
RUN chmod a+x /var/www/ttrss-entrypoint.sh

ENTRYPOINT ["/var/www/ttrss-entrypoint.sh"]

