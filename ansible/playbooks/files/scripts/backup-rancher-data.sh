#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

CONTAINER_NAME='rancher'
DATE=$(date +"%Y-%m-%d-%H.%m.%S")
VERSION="stable"
RANCHER_IMAGE="rancher/rancher:$VERSION"
DATA_CONTAINER="rancher-data-$DATE"
BACKUP_DIR='/containers/data/rancher2/'


# Stop Rancher container
docker stop $CONTAINER_NAME

# Replicate volumes to DATA_CONTAINER
docker create --volumes-from "$CONTAINER_NAME" --name "$DATA_CONTAINER" "$RANCHER_IMAGE"
# Tar and gz Rancher data
docker run  --volumes-from "$DATA_CONTAINER" -v $PWD:/backup:z busybox tar pzcf "/backup/rancher-data-backup-$VERSION-$DATE.tar.gz" /var/lib/rancher

# Move to a backed up directory
mv "rancher-data-backup-$VERSION-$DATE.tar.gz" $BACKUP_DIR

# Clean up data container
docker stop $DATA_CONTAINER
docker rm $DATA_CONTAINER
docker rm $(docker ps -aq --filter ancestor=busybox)

# Clean up old backups older than the last 3
cd $BACKUP_DIR
find . -maxdepth 1 -type f -printf '%T@\t%p\0' | sort -z -nrk1 | tail -z -n +4 | cut -z -f2- | xargs -0 rm -f --

# Restart Rancher container
docker start $CONTAINER_NAME
