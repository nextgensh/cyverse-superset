#!/usr/bin/env sh
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > $HOME/.irods/irods_environment.json

touch hello_world.txt

# Create a folder to find the external volume
mkdir -p work/home/$IPLANT_USER/superset-sqlite

export SUPERSET_HOME=/home/superset/work/home/$IPLANT_USER/superset-sqlite

superset db upgrade && \
    superset fab create-admin --username $SUPERSET_ADMIN_USER --firstname "Superset" \
                                --lastname "admin" --email "admin@foo.org" \
                                --password $SUPERSET_ADMIN_PASS && \
superset init

exec superset run -h 0.0.0.0 -p 9088 --with-threads
