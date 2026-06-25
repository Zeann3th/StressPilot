#!/bin/bash
set -euo pipefail

# Fetch the latest release info from GitHub API
RELEASE_JSON=$(curl -s https://api.github.com/repos/Zeann3th/StressPilotV3/releases/latest)

# Extract tag name (e.g., v3.0.4)
TAG_NAME=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
echo "Latest backend release tag is $TAG_NAME"

# Find the download URL for the jar file (pattern stresspilot-*.jar)
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -oE 'https://github.com/Zeann3th/StressPilotV3/releases/download/[^"]+\.jar' | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Could not find any .jar asset in the latest release."
  exit 1
fi

echo "Downloading backend jar from: $DOWNLOAD_URL"
mkdir -p assets/core
curl -L -o assets/core/app.jar "$DOWNLOAD_URL"
echo "Backend jar placed successfully at assets/core/app.jar"
