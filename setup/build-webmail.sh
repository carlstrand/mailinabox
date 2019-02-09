#!/bin/bash

workdir_src="/tmp/rcube-src-git"

git clone https://github.com/roundcube/roundcubemail.git ${workdir_src}
git checkout master

${workdir_src}/bin/install-jsdeps.sh
${workdir_src}/bin/jsshrink.sh
${workdir_src}/bin/updatecss.sh
${workdir_src}/bin/cssshrink.sh

(cd "${workdir_src}" && curl -sS https://getcomposer.org/installer | php -- --install-dir=/tmp/)
(cd "${workdir_src}" && mv composer.json-dist composer.json && php /tmp/composer.phar install --prefer-dist --no-dev)
rm -rf tests plugins/*/tests .git* .tx* index-test.php Dockerfile vendor/pear/*/tests vendor/*/*/.git* vendor/pear/crypt_gpg/tools vendor/pear/console_commandline/docs vendor/pear/mail_mime/scripts vendor/pear/net_ldap2/doc vendor/pear/net_sm$

tar -czvf /tmp/roundcubemail-release-complete.tar.gz /tmp/rcube-src-git
