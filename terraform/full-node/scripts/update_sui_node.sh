#!/bin/bash

# Configuration
SCRIPT_DIR="/opt/sui"
CURRENT_VERSION_FILE="$SCRIPT_DIR/current_version.txt"
INSTALL_PATH="/opt/sui/bin"
SLACK_SECRET_NAME=$1

# Install jq if its not installed
if ! command -v jq &> /dev/null; then
  echo "jq could not be found, attempting to install..."
  apt-get update && apt-get install -y jq
fi

echo "Fetching the latest 5 releases information"
RELEASES_DATA=$(curl -s "https://api.github.com/repos/MystenLabs/sui/releases?per_page=5")

# Parse the latest mainnet release tag using jq
LATEST_MAINNET_TAG=$(echo "$RELEASES_DATA" | jq -r '.[] | select(.tag_name | test("mainnet")) | .tag_name' | head -1)

if [ -z "$LATEST_MAINNET_TAG" ]; then
    echo "No mainnet release found. Exiting."
    exit 1
fi

echo "Latest mainnet tag is $LATEST_MAINNET_TAG"

# Fetch tag details to get the commit SHA. This doesn't contain the commit SHA that we need to install the right version.
TAG_DETAILS=$(curl -s "https://api.github.com/repos/MystenLabs/sui/git/refs/tags/$LATEST_MAINNET_TAG")
COMMIT_URL=$(echo "$TAG_DETAILS" | jq -r '.object.url')

# Fetch the actual commit SHA from the commit URL
COMMIT_DETAILS=$(curl -s "$COMMIT_URL")
ACTUAL_COMMIT_SHA=$(echo "$COMMIT_DETAILS" | jq -r '.object.sha')

if [ -z "$ACTUAL_COMMIT_SHA" ]; then
    echo "Failed to fetch the actual commit SHA. Exiting."
    exit 1
fi

echo "Latest commit SHA for mainnet is $ACTUAL_COMMIT_SHA"

# Read the current version from file
if [ -f "$CURRENT_VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat $CURRENT_VERSION_FILE)
else
    CURRENT_VERSION=""
fi

send_slack_message() {
  local SLACK_MESSAGE=$1
  SLACK_WEBHOOK_URL=$(gcloud secrets versions access latest --secret="${SLACK_SECRET_NAME}" 2>/dev/null)
  if [ -n "$SLACK_WEBHOOK_URL" ]; then
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${SLACK_MESSAGE}\"}" "${SLACK_WEBHOOK_URL}"
  else
    echo "Slack webhook URL not available. Unable to send."
  fi
}
# Compare the current version with the latest commit SHA
if [ "$ACTUAL_COMMIT_SHA" != "$CURRENT_VERSION" ]; then
    echo "A new mainnet release was found: $LATEST_MAINNET_TAG ($LATEST_COMMIT_SHA). Updating..."

    echo "Removing the old binary..."
    rm -f $INSTALL_PATH/sui-node

    echo "Downloading the latest Sui Node binary"
    wget -P $INSTALL_PATH "https://releases.sui.io/${ACTUAL_COMMIT_SHA}/sui-node"

    echo "Setting permissions on the new binary"
    chown -R sui:sui $INSTALL_PATH
    chmod 544 $INSTALL_PATH/sui-node

    echo $ACTUAL_COMMIT_SHA > $CURRENT_VERSION_FILE

    echo "Stopping the Sui Full Node service"
    systemctl stop sui-node
    echo "Restarting the Sui Full Node service"
    systemctl start sui-node

    echo "Update completed successfully."

    if [ -n "$SLACK_SECRET_NAME" ]; then
      SLACK_MESSAGE="SUI Node updated successfully to version $LATEST_MAINNET_TAG ($ACTUAL_COMMIT_SHA)."
      send_slack_message "$SLACK_MESSAGE"
    fi
    
else
    echo "No update is needed. Current version $CURRENT_VERSION is up to date."
fi
