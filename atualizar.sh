#!/bin/bash


echo "" > /opt/redmine/log/production.log
echo "" > /var/log/apache2/error.log
git pull origin main
touch /opt/redmine/tmp/restart.txt


