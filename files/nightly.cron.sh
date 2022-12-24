#!/bin/sh
cd /app
./manage.py prunepings
./manage.py prunenotifications
./manage.py pruneusers
./manage.py prunetokenbucket
./manage.py pruneflips
./manage.py prunepingsslow
