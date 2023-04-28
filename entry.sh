#!/usr/bin/env sh
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' | envsubst > $HOME/.irods/irods_environment.json

exec superset run -h 0.0.0.0 -p 9088 --with-threads --reload --debugger
