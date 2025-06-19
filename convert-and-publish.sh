#!/usr/bin/env bash

set -e

DOWNLOAD_URL="$1"

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Usage: $0 <github-release-download-url>"
  exit 1
fi

# Extract version, filename, and base name
# Handle both v-prefixed (v1.2.3) and non-prefixed (1.2.3) version formats
VERSION=$(echo "$DOWNLOAD_URL" | sed -n 's|.*/download/\([^/]*\)/.*|\1|p')
FILENAME=$(basename "$DOWNLOAD_URL")
BASE_NAME="${FILENAME%.s9pk}"

# Extract repo name and GitHub username
GITHUB_USER=$(echo "$DOWNLOAD_URL" | sed -n 's|https://github.com/\([^/]*\)/.*|\1|p')
REPO=$(echo "$DOWNLOAD_URL" | sed -n 's|https://github.com/[^/]*/\([^/]*\)/.*|\1|p')

V2_FILENAME="${BASE_NAME}V2.s9pk"
V2_UPLOAD_URL="https://github.com/${GITHUB_USER}/${REPO}/releases/download/${VERSION}/${V2_FILENAME}"

echo "[*] Checking if $V2_FILENAME already exists on GitHub..."
if curl --silent --head --fail "$V2_UPLOAD_URL" >/dev/null; then
  echo "[!] V2 package already exists at:"
  echo "    $V2_UPLOAD_URL"
  printf "Do you want to override it? [y/N]: "
  read answer
  case "$answer" in
  [yY][eE][sS] | [yY])
    echo "[*] Proceeding with override..."
    ;;
  *)
    echo "[x] Aborting to avoid overwrite."
    exit 0
    ;;
  esac
fi

echo "[*] Downloading $FILENAME from $DOWNLOAD_URL"
curl -L -o "$FILENAME" "$DOWNLOAD_URL"

echo "[*] Converting $FILENAME to V2 format (in-place)"
start-cli s9pk convert "$FILENAME"

echo "[*] Renaming $FILENAME to $V2_FILENAME"
mv "$FILENAME" "$V2_FILENAME"

echo "[*] Checking if release $VERSION exists in ${GITHUB_USER}/${REPO}..."
if ! gh release view "$VERSION" --repo "${GITHUB_USER}/${REPO}" &>/dev/null; then
  echo "[!] Release $VERSION not found. This could be because:"
  echo "    1. The release tag might be different from the version in the URL"
  echo "    2. You might not have access to the repository"
  echo ""
  echo "    Listing available releases:"
  gh release list --repo "${GITHUB_USER}/${REPO}"
  echo ""
  echo "    Please enter the correct release tag to use (or press Enter to use '$VERSION'):"
  read RELEASE_TAG
  if [ -n "$RELEASE_TAG" ]; then
    VERSION="$RELEASE_TAG"
    # Update V2_UPLOAD_URL with the new version
    V2_UPLOAD_URL="https://github.com/${GITHUB_USER}/${REPO}/releases/download/${VERSION}/${V2_FILENAME}"
  fi
fi

echo "[*] Uploading $V2_FILENAME to GitHub release $VERSION"
gh release upload "$VERSION" "$V2_FILENAME" --repo "${GITHUB_USER}/${REPO}" --clobber

echo "[*] Waiting for GitHub to process the upload (2 seconds)..."
sleep 2

# Calculate SHA-256 checksum
CHECKSUM=$(shasum -a 256 "$V2_FILENAME" | awk '{print $1}')
echo "[*] SHA-256 checksum: $CHECKSUM"

# Get current release notes and append checksum
echo "[*] Updating release notes with checksum..."
CURRENT_NOTES=$(gh release view "$VERSION" --repo "${GITHUB_USER}/${REPO}" --json body --jq .body)
NEW_NOTES="${CURRENT_NOTES}

## V2 Package Checksum
\`\`\`
${CHECKSUM}  ${V2_FILENAME}
\`\`\`"

# Update release notes
echo "$NEW_NOTES" | gh release edit "$VERSION" --repo "${GITHUB_USER}/${REPO}" --notes-file -

echo "[*] Publishing to alpha registry"
start-cli --registry https://alpha-registry-x.start9.com registry package add "$V2_FILENAME" "$V2_UPLOAD_URL"

echo "[✓] SHA-256 checksum:"
shasum -a 256 "$V2_FILENAME"
