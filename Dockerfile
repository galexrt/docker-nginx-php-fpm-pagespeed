FROM centos:7.2.1511

MAINTAINER Alexander Trost <galexrt@googlemail.com>

RUN echo '[nginx]' > /etc/yum.repos.d/nginx.repo && \
    echo 'name=nginx repo' >> /etc/yum.repos.d/nginx.repo && \
    echo 'baseurl=http://nginx.org/packages/centos/7/$basearch/' >> /etc/yum.repos.d/nginx.repo && \
    echo 'gpgcheck=0' >> /etc/yum.repos.d/nginx.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/nginx.repo && \
    yum -q update -y && \
    yum -q install -y python-setuptools nginx php-fpm php-common php-mysql php-xml php-pgsql \
        php-pecl-memcache php-pdo php-odbc php-mysql php-mbstring php-ldap \
        php-intl php-gd php-bcmath php-soap php-process php-pear php-recode \
        php-pspell php-snmp php-xmlrpc && \
    easy_install pip && \
    pip install supervisor && \
    mkdir -p /var/log/supervisord/ && \
    sed -i 's/;cgi.fix_pathinfo.*/cgi.fix_pathinfo=0/g' /etc/php.ini && \
    sed -i 's/user.*/user = nginx/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/group.*/group = nginx/g' /etc/php-fpm.d/www.conf && \
    yum clean all && \
    rm -rf /tmp/* /var/tmp/*

ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/supervisord.conf"]
