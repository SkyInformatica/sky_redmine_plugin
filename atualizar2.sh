#!/bin/bash

service apache2 stop
echo "" > /opt/redmine/log/production.log
echo "" > /var/log/apache2/error.log
git pull origin main
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
service apache2 start
