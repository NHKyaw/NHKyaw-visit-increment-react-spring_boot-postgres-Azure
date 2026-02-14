#!/bin/bash
set -e

echo "Removing Old Containers and Deploying New Ones with IMAGE_TAG=${IMAGE_TAG}"
cd /home/ubuntu/docker/
sudo /usr/bin/docker compose down
sudo /usr/bin/docker rmi nhkyaw/visit-record-app:backend-${IMAGE_TAG} || echo "No old backend image to remove"
sudo /usr/bin/docker rmi nhkyaw/visit-record-app:frontend-${IMAGE_TAG} || echo "No old frontend image to remove"


sudo /usr/bin/docker pull nhkyaw/visit-record-app:backend-${IMAGE_TAG}
sudo /usr/bin/docker pull nhkyaw/visit-record-app:frontend-${IMAGE_TAG}

sudo /usr/bin/docker compose --env-file .env.${IMAGE_TAG} -f docker-compose.yaml up -d