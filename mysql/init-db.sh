#!/bin/bash
set -e

# Run the original entrypoint script
/usr/local/bin/docker-entrypoint.sh mysqld &

# Wait for MySQL to start
until mysqladmin ping -h "127.0.0.1" --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 5
done

# Execute the SQL script
mysql -u root -p$MYSQL_ROOT_PASSWORD < /docker-entrypoint-initdb.d/00_setup_db.sql

# Keep the container running
tail -f /dev/null