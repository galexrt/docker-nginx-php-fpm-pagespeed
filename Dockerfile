FROM centos:7

MAINTAINER Alexander Trost <galexrt@googlemail.com>

ENV NPS_VERSION=1.12.34.2-beta NGINX_VERSION=1.11.8

RUN yum -q update -y && \
    yum -q install -y wget unzip gcc-c++ pcre-devel zlib-devel make unzip \
        openssl python-setuptools php-fpm php-common php-mysql php-xml php-pgsql \
        php-pecl-memcache php-pdo php-odbc php-mysql php-mbstring php-ldap \
        php-intl php-gd php-bcmath php-soap php-process php-pear php-recode \
        php-pspell php-snmp php-xmlrpc && \
    adduser -r -m -d /var/cache/nginx -s /sbin/nologin nginx && \
    easy_install pip && \
    pip install supervisor && \
    mkdir -p /var/log/supervisord/ /www /certs /configs && \
    sed -i 's/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/g' /etc/php.ini && \
    sed -i 's/user.*/user = nginx/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/group.*/group = nginx/g' /etc/php-fpm.d/www.conf && \
    cd /root && \
    wget -q https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}.zip && \
    unzip v${NPS_VERSION}.zip && \
    cd ngx_pagespeed-${NPS_VERSION}/ && \
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
    wget -q ${psol_url} && \
    tar -xzvf $(basename ${psol_url})

RUN cd /root && \
    wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xvzf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION}/ && \
    ./configure --add-module=$HOME/ngx_pagespeed-${NPS_VERSION} ${PS_NGX_EXTRA_FLAGS} && \
    make && \
    make install && \
    rm -f /etc/nginx/conf.d/* && \
    mkdir -p /var/ngx_pagespeed_cache /etc/nginx/conf.d/ /var/log/nginx /var/log/pagespeed /var/lib/php/session && \
    chown nginx:nginx -R /var/ngx_pagespeed_cache /var/log/pagespeed /var/lib/php/session && \
    rm -rf /root/* && \
    yum -q remove -y wget tar unzip gcc-c++ pcre-devel zlib-devel make && \
    yum -q clean all && \
    rm -rf /tmp/* /var/tmp/* /var/lib/yum/* /var/cache/yum/*

ADD nginx.conf /usr/local/nginx/conf/nginx.conf
ADD nginx-default.conf /etc/nginx/conf.d/default.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf

VOLUME ["/www", "/certs", "/configs"]

ENTRYPOINT ["/usr/bin/supervisord"]
