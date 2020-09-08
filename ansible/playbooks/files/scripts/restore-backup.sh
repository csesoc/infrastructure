#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Use this to restore the cluster if it has failed terribly
# You still need to restore /containers/data from the CSE machine if that got corrupted

RANCHER_CONTAINER="rancher"
RANCHER_BACKUP_DIR="/containers/data/rancher2"

echo "Stopping container $RANCHER_CONTAINER"
docker stop $RANCHER_CONTAINER

# Find backup file (the latest)
BACKUP_ZIP=$(ls -t $RANCHER_BACKUP_DIR | head -n1)
echo "Restoring $BACKUP_ZIP"

# Run backup procedure
docker run  --volumes-from $RANCHER_CONTAINER -v $RANCHER_BACKUP_DIR:/backup \
 busybox sh -c "rm /var/lib/rancher/* -rf  && tar pzxvf /backup/$BACKUP_ZIP"

# Copy kubernetes internal certificates if missing
echo "Overwriting internal kubernetes certificates"
rm -rf /etc/kubernetes/.tmp/*
cp -a /etc/kubernetes/ssl/. /etc/kubernetes/.tmp

echo "Restarting container"
docker start $RANCHER_CONTAINER
