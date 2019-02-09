#!/bin/bash

sudo apt-fast update
sudo apt-fast remove -qq -y owncloud*
#apt-get purge -qq -y owncloud*
sudo apt upgrade

#sudo apt-fast update
#sudo apt-fast install -y <package-name>
#sudo apt-fast dist-upgrade
#sudo apt-fast remove

sudo apt-fast aria2 bc bind9 bind9-host build-essential ca-certificates certbot coreutils cron curl dbconfig-common default-jre dialog dns \
dovecot-antispam dovecot-core dovecot-imapd dovecot-lmtpd dovecot-managesieved dovecot-pop3d dovecot-sieve dovecot-sqlite duplicity fail2ban gcc git \
google-perftools haveged ldnsutils libawl-php libcgi-fast-perl libgd-dev libgeoip-dev libgeoip1 libgoogle-perftools-dev libjs-jquery libjs-jquery-mousewheel \
libmagic1 libmail-dkim-perl libpcre3 libpcre3-dev libperl-dev libssl-dev libxml2-dev libxslt-dev locales munin munin-node netcat-openbsd nsd ntp opendkim-tools opendmarc \
openssh-client openssl pendkim php php-apcu php-cli php-common php-curl php-dev php-fpm php-gd php-imap php-intl php-json php-mbstring php-pear php-pspell php-soap php-sqlite3 \
php-xml php-xsl php-zip pollinate postfix postfix-pcre postfix-sqlite postgrey python-pip python3 python3-dev python3-pip pyzor razor rsyslog sed software-properties-common spampd \
sqlite3 sudo tinymce ufw unattended-upgrades unzip uuid-dev virtualenv wget zlib1g zlib1g-dev zlibc


sudo apt autoremove
