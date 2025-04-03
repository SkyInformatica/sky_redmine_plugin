#!/bin/bash


echo "" > /opt/redmine/log/production.log
echo "" > /var/log/apache2/error.log
git pull origin main
touch /opt/redmine/tmp/restart.txt

chown -R www-data:www-data /opt/redmine-5.1.1/public/plugin_assets/sky_redmine_plugin/
chmod -R 775 /opt/redmine-5.1.1/public/plugin_assets/sky_redmine_plugin/

