#!/usr/bin/env bash
source /home/utils.sh

set -e
set -o pipefail


trap "$(print_error $LINENO)" EXIT


export DEBIAN_FRONTEND="noninteractive"
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

USER=$(whoami)
SQL_ROOT_PASSWORD=$1
DB_NAME=$2
DB_PASSWORD=$3



function install_apache_server {
  info 'INSTALLING APACHE SERVER ======>'
  sudo apt update -y
  sudo apt-get upgrade -y
  sudo apt-get install apache2 -y
  sudo systemctl start apache2.service
  success 'APACHE SERVER SUCCESSFULLY INSTALLED =======>'
}


function install_mysql_database {
  info 'INSTALLING MYSQL DATABASE ======>'
  echo "mysql-server mysql-server/root_password password ${SQL_ROOT_PASSWORD}" | sudo debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password ${SQL_ROOT_PASSWORD}" | sudo debconf-set-selections
  sudo apt-get install mysql-server -y
  success 'MYSQL DATABASE SUCCESSFULLY INSTALLED =======>'
}


function install_php_and_core_deps {
  info 'INSTALLING PHP AND CORE DEPENDENCIES ======>'
  sudo apt-get install php -y
  sudo apt-get install -y php-{bcmath,bz2,intl,gd,mbstring,mcrypt,mysql,zip}
  sudo apt-get install libapache2-mod-php -y
  success 'PHP AND CORE DEPENDENCIES SUCCESSFULLY INSTALLED =======>'
}


function start_apache_mysql_on_boot {
  info 'CONFIGURING MYSQL AND APACHE STARTUP ON BOOT ======>'
  sudo systemctl enable apache2.service
  sudo /lib/systemd/systemd-sysv-install enable mysql
}


function restart_apache_server {
  info 'RESTARTING APACHE SERVER ======>'
  sudo systemctl restart apache2.service
  success 'APACHE SERVER RESTARTED =======>'
}


function download_wordpress {
  info 'DOWNLOADING WORDPRESS =======>'
  wget -c http://wordpress.org/latest.tar.gz
  tar -xzvf latest.tar.gz
  sudo apt-get install rsync -y
  sudo rsync -av wordpress/* /var/www/html/
  sudo rm /var/www/html/index.html
  sudo chown -R www-data:www-data /var/www/html/
  sudo chmod -R 755 /var/www/html/
  success "WORDPRESS DOWNLOAD SUCCESSFULL =======>"
}


function create_wordpress_database {
  info "CREATING WORDPRESS DATABASE ========>"
  sudo mysql -p="${SQL_ROOT_PASSWORD}" -u "root" -Bse "CREATE DATABASE $DB_NAME;
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO '${USER}'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
  FLUSH PRIVILEGES;"
  success "WORDPRESS DATABASE SUCCESSFULLY CREATED =======>"
}


function configure_wordpress {
  info "CONNECTING WORDPRESS APP TO DATABASE========>"
  sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sudo perl -pi -e "s'database_name_here'"$DB_NAME"'g" /var/www/html/wp-config.php
	sudo perl -pi -e "s'username_here'"$USER"'g" /var/www/html/wp-config.php
	sudo perl -pi -e "s'password_here'"$DB_PASSWORD"'g" /var/www/html/wp-config.php
  sudo systemctl restart apache2.service 
  sudo systemctl restart mysql.service 
  success "DEPLOYED WORDPRESS APPLICATION =======>"
}


function main {
  install_apache_server
  install_mysql_database
  install_php_and_core_deps
  start_apache_mysql_on_boot
  restart_apache_server
  download_wordpress
  create_wordpress_database
  configure_wordpress
}

main "$@"
