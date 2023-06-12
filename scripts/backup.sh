#!/bin/bash

# Get the name of the current iplant user so we can form the path
# We cannot use the env variables here, as they are not set in the context of the cron job being called.
IPLANT_USER=`ls -1 /data-store/iplant/home/ | grep --invert-match "shared"`
cp /var/superset/superset.db /data-store/iplant/home/"$IPLANT_USER"/superset-sqlite/
# Also copy it to the output folder
cp /var/superset/superset.db /data-store/output/
# A test copy to the working directory (used for local testing)
cp /var/superset/superset.db /var/superset-home/
