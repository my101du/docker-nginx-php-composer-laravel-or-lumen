FROM daocloud.io/ubuntu:14.04
MAINTAINER Eric Zhang <my101du@gmail.com>
 
# replace default apt source to China apt source
COPY ./sources_cn.list /etc/apt/sources.list

# update system
RUN apt-get update
RUN apt-get -y upgrade

# install nginx and replace default config file with user's default.conf
RUN apt-get -y install nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
COPY default.conf /etc/nginx/sites-available/default

# install PHP(php-fpm) and extionsions, libapache2-mod-php5 includes all librarires which Laravel needs 
RUN apt-get -y install php5-fpm php5-cli git libapache2-mod-php5 php-pear libmcrypt-dev libz-dev wget libxml2 php5-curl mcrypt php5-mcrypt php5-memcache php5-json php5-gd php5-mysql php5-xmlrpc

# change fix_pathinfo param value
RUN sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini

# install composer
RUN php -v
RUN cd ~ \
	&& php -r "readfile('https://getcomposer.org/installer');" | php -d detect_unicode=off \
	&& sudo mv composer.phar /usr/local/bin/composer

# change default composer packages source to China mirror
RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com

# clean files
RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# initial application work folder，install an empty Laravel project
RUN mkdir -p /app && rm -fr /usr/share/nginx/html && ln -s /app /usr/share/nginx/html
RUN chmod -R 0777 /app

# create an empty Laravel project
RUN cd /app && pwd && ls -al /app
RUN composer create-project laravel/laravel /app  --prefer-dist

# replace the work folder(Laravel initial files) to user's code 
COPY ./wwwroot /app
COPY ./wwwroot/.env.example /app/.env
RUN cd /app && ls -al /app && composer install && composer update --no-scripts

# optimize laravel
RUN cd /app \
	&& cat public/index.php
## && sudo php artisan optimize \
#	&& sudo php artisan config:cache \
#	&& sudo php artisan route:cache

# ports and workdir
WORKDIR /app

EXPOSE 80
 
# start services
CMD service php5-fpm start && nginx