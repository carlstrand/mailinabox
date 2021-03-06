#!/bin/bash
# Webmail with Roundcube
# ----------------------

source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars

echo "Installing Roundcube (webmail)..."

VERSION=custom1
HASH=90c7900ccf7b2f46fe49c650d5adb9b85ee9cc22
PERSISTENT_LOGIN_VERSION=dc5ca3d3f4415cc41edb2fde533c8a8628a94c76
HTML5_NOTIFIER_VERSION=4b370e3cd60dabd2f428a26f45b677ad1b7118d5
CARDDAV_VERSION=3.0.3
CARDDAV_HASH=d1e3b0d851ffa2c6bd42bf0c04f70d0e1d0d78f8
UPDATE_KEY=$VERSION:$PERSISTENT_LOGIN_VERSION:$HTML5_NOTIFIER_VERSION:$CARDDAV_VERSION
RCM_DIR=/usr/local/lib/roundcubemail
RCM_PLUGIN_DIR=${RCM_DIR}/plugins
RCM_CONFIG=${RCM_DIR}/config/config.inc.php

needs_update=0 #NODOC

if [ ! -f /usr/local/lib/roundcubemail/version ]; then
    needs_update=1 #NODOC
    
    elif [[ "$UPDATE_KEY" != $(cat /usr/local/lib/roundcubemail/version) ]]; then
    needs_update=1 #NODOC
fi


if [ $needs_update == 1 ]; then
    source setup/build-webmail.sh
    
    tar -C /usr/local/lib --no-same-owner -zxf /tmp/roundcubemail-release-complete.tar.gz
    
    rm -rf /usr/local/lib/roundcubemail
    
    mv /usr/local/lib/tmp/rcube-src-git $RCM_DIR
    rm -f /tmp/roundcubemail-release-complete.tar.gz
    
    git_clone https://github.com/mfreiholz/Roundcube-Persistent-Login-Plugin.git $PERSISTENT_LOGIN_VERSION '' ${RCM_PLUGIN_DIR}/persistent_login
    git_clone https://github.com/kitist/html5_notifier.git $HTML5_NOTIFIER_VERSION '' ${RCM_PLUGIN_DIR}/html5_notifier
    wget_verify https://github.com/blind-coder/rcmcarddav/releases/download/v${CARDDAV_VERSION}/carddav-${CARDDAV_VERSION}.zip $CARDDAV_HASH /tmp/carddav.zip
    
    unzip -q /tmp/carddav.zip -d ${RCM_PLUGIN_DIR}
    rm -f /tmp/carddav.zip
    echo $UPDATE_KEY > ${RCM_DIR}/version
fi

# ### Configuring Roundcube

# Generate a safe 24-character secret key of safe characters.
SECRET_KEY=$(dd if=/dev/urandom bs=1 count=18 2>/dev/null | base64 | fold -w 24 | head -n 1)

# Create a configuration file.
#
# For security, temp and log files are not stored in the default locations
# which are inside the roundcube sources directory. We put them instead
# in normal places.
cat > $RCM_CONFIG <<EOF;
<?php
/*
 * Do not edit. Written by Mail-in-a-Box. Regenerated on updates.
 */
\$config = array();
\$config['log_dir'] = '/var/log/roundcubemail/';
\$config['temp_dir'] = '/var/tmp/roundcubemail/';
\$config['db_dsnw'] = 'sqlite:///$STORAGE_ROOT/mail/roundcube/roundcube.sqlite?mode=0640';
\$config['default_host'] = 'ssl://localhost';
\$config['default_port'] = 993;
\$config['imap_conn_options'] = array(
  'ssl'         => array(
     'verify_peer'  => false,
     'verify_peer_name'  => false,
   ),
 );
\$config['imap_timeout'] = 15;
\$config['smtp_server'] = 'tls://127.0.0.1';
\$config['smtp_port'] = 587;
\$config['smtp_user'] = '%u';
\$config['smtp_pass'] = '%p';
\$config['smtp_conn_options'] = array(
  'ssl'         => array(
     'verify_peer'  => false,
     'verify_peer_name'  => false,
   ),
 );
\$config['support_url'] = 'https://mailinabox.email/';
\$config['product_name'] = '$PRIMARY_HOSTNAME Webmail';
\$config['des_key'] = '$SECRET_KEY';
\$config['plugins'] = array('html5_notifier', 'archive', 'zipdownload', 'password', 'managesieve', 'jqueryui', 'persistent_login', 'carddav', 'autologon', 'identity_select', 'identicon', 'redundant_attachments', 'show_additional_headers', 'virtuser_file', 'userinfo');
\$config['skin'] = 'elastic';
\$config['login_autocomplete'] = 2;
\$config['password_charset'] = 'UTF-8';
\$config['junk_mbox'] = 'Spam';
\$config['identity_select_headers'] = array('Delivered-To');
\$config['redundant_attachments_fallback'] = false;
\$config['redundant_attachments_cache_ttl'] = 12 * 60 * 60;
\$config['zipdownload_attachments'] = 1;
\$config['zipdownload_selection'] = '3GB';
\$config['zipdownload_charset'] = 'ISO-8859-1';
?>
EOF

#composer require boressoft/ident_switch
#composer require cor/message_highlight
#composer require alexandregz/twofactor_gauthenticator
#composer require dsoares/rcguard
#composer require roundcube/elastic4mobile
#composer require pf4public/fetchmail
#composer require dsoares/lastlogin
#composer require san4op/folder_info
#composer require roundcube/chbox
#composer require sbehuret/user_config
#composer require ss88/gravatar_imgs
#composer require random-cuber/font_awesome
#composer require roundcube/virtual_user_mapping


# Configure CardDav
cat > ${RCM_PLUGIN_DIR}/carddav/config.inc.php <<EOF;
<?php
/* Do not edit. Written by Mail-in-a-Box. Regenerated on updates. */
\$prefs['_GLOBAL']['hide_preferences'] = true;
\$prefs['_GLOBAL']['suppress_version_warning'] = true;
\$prefs['ownCloud'] = array(
	 'name'         =>  'ownCloud',
	 'username'     =>  '%u', // login username
	 'password'     =>  '%p', // login password
	 'url'          =>  'https://${PRIMARY_HOSTNAME}/cloud/remote.php/carddav/addressbooks/%u/contacts',
	 'active'       =>  true,
	 'readonly'     =>  false,
	 'refresh_time' => '02:00:00',
	 'fixed'        =>  array('username','password'),
	 'preemptive_auth' => '1',
	 'hide'        =>  false,
);
?>
EOF

# Create writable directories.
mkdir -p /var/log/roundcubemail /var/tmp/roundcubemail $STORAGE_ROOT/mail/roundcube
chown -R www-data.www-data /var/log/roundcubemail /var/tmp/roundcubemail $STORAGE_ROOT/mail/roundcube

# Ensure the log file monitored by fail2ban exists, or else fail2ban can't start.
sudo -u www-data touch /var/log/roundcubemail/errors

# Password changing plugin settings
# The config comes empty by default, so we need the settings
# we're not planning to change in config.inc.dist...
cp ${RCM_PLUGIN_DIR}/password/config.inc.php.dist \
${RCM_PLUGIN_DIR}/password/config.inc.php

tools/editconf.py ${RCM_PLUGIN_DIR}/password/config.inc.php \
"\$config['password_minimum_length']=8;" \
"\$config['password_db_dsn']='sqlite:///$STORAGE_ROOT/mail/users.sqlite';" \
"\$config['password_query']='UPDATE users SET password=%D WHERE email=%u';" \
"\$config['password_dovecotpw']='/usr/bin/doveadm pw';" \
"\$config['password_dovecotpw_method']='SHA512-CRYPT';" \
"\$config['password_dovecotpw_with_method']=true;"

# so PHP can use doveadm, for the password changing plugin
usermod -a -G dovecot www-data

# set permissions so that PHP can use users.sqlite
# could use dovecot instead of www-data, but not sure it matters
chown root.www-data $STORAGE_ROOT/mail
chmod 775 $STORAGE_ROOT/mail
chown root.www-data $STORAGE_ROOT/mail/users.sqlite
chmod 664 $STORAGE_ROOT/mail/users.sqlite

# Fix Carddav permissions:
chown -f -R root.www-data ${RCM_PLUGIN_DIR}/carddav
# root.www-data need all permissions, others only read
chmod -R 774 ${RCM_PLUGIN_DIR}/carddav

# Run Roundcube database migration script (database is created if it does not exist)
${RCM_DIR}/bin/updatedb.sh --dir ${RCM_DIR}/SQL --package roundcube
chown www-data:www-data $STORAGE_ROOT/mail/roundcube/roundcube.sqlite
chmod 664 $STORAGE_ROOT/mail/roundcube/roundcube.sqlite

# Enable PHP modules.
phpenmod -v php mcrypt imap mbstring zlib
restart_service php7.2-fpm
