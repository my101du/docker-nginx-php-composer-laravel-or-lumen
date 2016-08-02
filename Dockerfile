FROM daocloud.io/ubuntu:14.04
MAINTAINER Eric Zhang <my101du@gmail.com>
 
# use china apt-get source
COPY ./sources_cn.list /etc/apt/sources.list


# update system
RUN apt-get update
RUN apt-get -y upgrade


# install php dependences
RUN apt-get install -y libmcrypt-dev libz-dev git wget libxml2


# install nginx
RUN apt-get -y install nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf


# install PHP and extionsions, libapache2-mod-php5 includes all laravel needs library
RUN apt-get -y install php5-fpm php5-cli libapache2-mod-php5 php-pear php5-curl mcrypt php5-mcrypt php5-memcache php5-json php5-gd php5-mysql php5-xmlrpc


# change fix_pathinfo param value
RUN sed -i s/\;cgi\.fix_pathinfo\s*\=\s*1/cgi.fix_pathinfo\=0/ /etc/php5/fpm/php.ini


# clean files
RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# install composer, curl -sS method always return this error below
# mv: cannot stat 'composer.phar': No such file or directory 
RUN php -v
RUN cd ~ \
	&& php -r "readfile('https://getcomposer.org/installer');" | php -d detect_unicode=off \
	&& sudo mv composer.phar /usr/local/bin/composer


# initial application work folder
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
COPY default.conf /etc/nginx/sites-available/default

RUN mkdir -p /app && rm -fr /usr/share/nginx/html && ln -s /app /usr/share/nginx/html

COPY . /app
RUN chmod -R 0777 /app
COPY ./.env.example /app/.env

RUN cd /app && pwd && sudo composer install


# optimize laravel
RUN sudo php artisan optimize
RUN sudo php artisan config:cache
RUN sudo php artisan route:cache


# ports and workdir
WORKDIR /app

EXPOSE 80
 

# start commands
CMD service php5-fpm start && nginx