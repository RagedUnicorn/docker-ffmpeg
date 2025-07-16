#!/bin/bash
set -e

# Script to manage versioning for docker-ffmpeg
# Generates tags in format: {ffmpeg}-alpine{alpine}-{build}

DOCKERFILE="Dockerfile"
VERSION_FILE=".version.json"

# Extract versions from Dockerfile
CURRENT_ALPINE=$(grep "^FROM alpine:" "$DOCKERFILE" | head -1 | cut -d':' -f2 | cut -d' ' -f1)
CURRENT_FFMPEG=$(grep "^ARG FFMPEG_VERSION=" "$DOCKERFILE" | cut -d'=' -f2)

# Read previous versions from version file
if [ -f "$VERSION_FILE" ]; then
    PREV_ALPINE=$(jq -r '.alpine_version' "$VERSION_FILE")
    PREV_FFMPEG=$(jq -r '.ffmpeg_version' "$VERSION_FILE")
    PREV_BUILD=$(jq -r '.build_number' "$VERSION_FILE")
else
    # Initialize if version file doesn't exist
    PREV_ALPINE=""
    PREV_FFMPEG=""
    PREV_BUILD=0
fi

# Determine build number
if [ "$CURRENT_ALPINE" != "$PREV_ALPINE" ] || [ "$CURRENT_FFMPEG" != "$PREV_FFMPEG" ]; then
    # Reset build number if Alpine or FFmpeg version changed
    BUILD_NUMBER=1
else
    # Increment build number for rebuilds with same versions
    BUILD_NUMBER=$((PREV_BUILD + 1))
fi

# Generate tag
TAG="${CURRENT_FFMPEG}-alpine${CURRENT_ALPINE}-${BUILD_NUMBER}"

# Update version file
cat > "$VERSION_FILE" <<EOF
{
  "ffmpeg_version": "$CURRENT_FFMPEG",
  "alpine_version": "$CURRENT_ALPINE",
  "build_number": $BUILD_NUMBER,
  "last_tag": "$TAG"
}
EOF

# Output the tag for use in workflows
echo "Generated tag: $TAG"
echo "tag=$TAG" >> "$GITHUB_OUTPUT"
echo "ffmpeg_version=$CURRENT_FFMPEG" >> "$GITHUB_OUTPUT"
echo "alpine_version=$CURRENT_ALPINE" >> "$GITHUB_OUTPUT"
echo "build_number=$BUILD_NUMBER" >> "$GITHUB_OUTPUT"
