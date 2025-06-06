#!/bin/bash

service apache2 stop
echo "" > /opt/redmine/log/production.log
echo "" > /var/log/apache2/error.log
bundle exec rake redmine:plugins:migrate NAME=sky_redmine_plugin VERSION=0 RAILS_ENV=production
git pull origin main
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
service apache2 start


chown -R www-data:www-data /opt/redmine-5.1.1/public/plugin_assets/sky_redmine_plugin/
chmod -R 775 /opt/redmine-5.1.1/public/plugin_assets/sky_redmine_plugin/


