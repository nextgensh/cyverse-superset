#!/usr/bin/env sh
#echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > $HOME/.irods/irods_environment.json

# Create a folder to find the external volume
mkdir -p /data-store/iplant/home/"$IPLANT_USER"/superset-sqlite

export SUPERSET_HOME=/var/superset

cd /data-store/iplant/home/"$IPLANT_USER"/superset-sqlite/

# Recover the database file from remote storage.
if [ -f superset.db ]; then
	echo "Local db file found, reusing it"
	cp superset.db /var/superset/
else
	echo "Local db file not found. Starting new."
fi

# Start the cron deamon
cron start

superset db upgrade 
superset fab create-admin --username "$SUPERSET_ADMIN_USER" --firstname "Superset" \
                                --lastname "admin" --email "admin@foo.org" \
                                --password "$SUPERSET_ADMIN_PASS"
superset init

exec superset run -h 0.0.0.0 -p 9088 --with-threads
