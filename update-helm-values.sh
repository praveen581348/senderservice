#!/bin/bash

# === CONFIGURATION ===
VALUES_FILE="helm/senderservice/values.yaml"
NEW_IMAGE_TAG=$1

if [ -z "$NEW_IMAGE_TAG" ]; then
  echo "Error: No image tag supplied"
  exit 1
fi

echo "Updating $VALUES_FILE with image tag: $NEW_IMAGE_TAG"

# Replace the image tag line in the values.yaml file
sed -i.bak "s/^  tag: .*/  tag: \"$NEW_IMAGE_TAG\"/" "$VALUES_FILE"

echo "Update complete. Here's the updated image tag line:"
grep 'tag:' "$VALUES_FILE"
