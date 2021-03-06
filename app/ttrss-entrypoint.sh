#!/bin/bash

set -Eeo pipefail

if [[ "$TTRSS_DB_TYPE" != "pgsql" ]] ; then
	echo "[$(date)] ERROR - pgsql is the only DB type supported by this script"
	exit 1
fi

echo "[$(date)] Setting up DB"

echo "[$(date)] Checking if DB is up..."
until psql --host "$TTRSS_DB_HOST" --port "$TTRSS_DB_PORT" --username "$TTRSS_DB_USER" --dbname "$TTRSS_DB_NAME" --command "select current_timestamp;" ; do
	>&2 echo "Waiting for postgress..."
	sleep 3
done


rowcount=$(psql --host "$TTRSS_DB_HOST" --port "$TTRSS_DB_PORT" --username "$TTRSS_DB_USER" --dbname "$TTRSS_DB_NAME" --tuples-only \
	--command "SELECT count(*) FROM information_schema.tables WHERE table_name like 'ttrss_%'" | awk '{print $1}')

echo "[$(date)] ttrss_* tables [$rowcount]"

if [[ "$rowcount" == "0" ]] ; then
	echo "[$(date)] No ttrss_* tables found - running schema script"
	psql --host $TTRSS_DB_HOST --port $TTRSS_DB_PORT --username $TTRSS_DB_USER --dbname $TTRSS_DB_NAME \
		--file /var/www/tt-rss/schema/ttrss_schema_pgsql.sql
else
	echo "[$(date)] Table ttrss_* detected - moving on..."
fi


echo "[$(date)] Setting up config.php"

cp /var/www/tt-rss/config.php-dist /var/www/tt-rss/config.php
sed -ri \
	-e "s#(define\('DB_HOST').*\$#\1, '$TTRSS_DB_HOST');#g" \
	-e "s#(define\('DB_TYPE').*\$#\1, '$TTRSS_DB_TYPE');#g" \
	-e "s#(define\('DB_USER').*\$#\1, '$TTRSS_DB_USER');#g" \
	-e "s#(define\('DB_NAME').*\$#\1, '$TTRSS_DB_NAME');#g" \
	-e "s#(define\('DB_PASS').*\$#\1, '$TTRSS_DB_PASSWORD');#g" \
	-e "s#(define\('DB_PORT').*\$#\1, '$TTRSS_DB_PORT');#g" \
	-e "s#(define\('SELF_URL_PATH').*\$#\1, '$TTRSS_SELF_URL_PATH');#g" \
	/var/www/tt-rss/config.php

echo "[$(date)] Running process..."

sudo -u www-data /usr/bin/php /var/www/tt-rss/update_daemon2.php & /usr/sbin/apache2ctl -D FOREGROUND

