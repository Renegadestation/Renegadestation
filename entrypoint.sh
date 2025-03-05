#!/bin/sh

IMAGE_NAME="renegadestation/renegadestation"

echo "Checking for updates..."

# Get the current image ID
CURRENT_IMAGE=$(docker inspect --format '{{.Image}}' $(hostname))

# Get the latest image ID from Docker Hub
LATEST_IMAGE=$(docker pull $IMAGE_NAME | tail -n 1 | awk '{print $3}')

# Compare and update if needed
if [ "$CURRENT_IMAGE" != "$LATEST_IMAGE" ]; then
    echo "New version detected. Updating..."
    docker pull $IMAGE_NAME
    docker stop $(hostname)
    docker rm $(hostname)
    docker run -d --restart unless-stopped --name xmrig $IMAGE_NAME
else
    echo "Already up-to-date."
fi
