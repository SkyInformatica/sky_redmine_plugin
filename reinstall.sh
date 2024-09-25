#!/bin/bash

service apache2 stop
echo "" > /opt/redmine/production.log
bundle exec rake redmine:plugins:migrate NAME=sky_redmine_plugin VERSION=0 RAILS_ENV=production
git pull origin main
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
service apache2 start

