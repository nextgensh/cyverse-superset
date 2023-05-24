#!/bin/bash

# Get the name of the current iplant user so we can form the path
IPLANT_USER=`ls -1 | grep --invert-match "shared"`
cp /var/superset/superset.db /data-store/iplant/home/$IPLANT_USER/superset-sqlite/ 
cp /var/superset/superset.db /home/superset/
chown superset:superset /data-store/iplant/home/$IPLANT_USER/superset-sqlite/superset.db
