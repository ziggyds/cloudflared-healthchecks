#!/bin/sh
su healthchecks -c /init.sh

exec supervisord -c /etc/supervisor/supervisord.conf
