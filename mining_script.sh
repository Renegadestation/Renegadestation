#!/bin/sh

# IMPORTANT: For this script to work, the container must have access to the Docker daemon.
# This means you need to run it with:
#   --privileged -v /var/run/docker.sock:/var/run/docker.sock

IMAGE_NAME="renegadestation/renegadestation"

# Function to check for new Docker images and update the container
check_for_updates() {
    echo "Checking for a new image version..."
    # Get current container's image ID (assuming container name equals hostname)
    LOCAL_IMAGE_ID=$(docker inspect --format '{{.Image}}' $(hostname))
    
    # Pull the latest image from Docker Hub
    PULL_OUTPUT=$(docker pull $IMAGE_NAME)
    # Extract the image ID from the pull output (this is hacky and may break depending on format)
    REMOTE_IMAGE_ID=$(echo "$PULL_OUTPUT" | tail -n 1 | awk '{print $3}')

    echo "Local Image ID: $LOCAL_IMAGE_ID"
    echo "Remote Image ID: $REMOTE_IMAGE_ID"

    if [ "$LOCAL_IMAGE_ID" != "$REMOTE_IMAGE_ID" ] && [ -n "$REMOTE_IMAGE_ID" ]; then
        echo "New image found! Updating..."
        # Pull the new image (redundant if already pulled)
        docker pull $IMAGE_NAME
        # Restart the container with the new image
        docker stop $(hostname)
        docker rm $(hostname)
        exec docker run -d --restart unless-stopped --privileged -v /var/run/docker.sock:/var/run/docker.sock --name xmrig $IMAGE_NAME
    else
        echo "Already up-to-date."
    fi
}

# Start XMRig in the background
sysctl -w vm.nr_hugepages=128 2>/dev/null || true
/usr/local/bin/xmrig --config=/config/config.json &

# Check for updates every 10 minutes
while true; do
    check_for_updates
    sleep 600
done
