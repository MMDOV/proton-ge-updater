#! /usr/bin/bash
set -euo pipefail
# make temp working directory
echo "Creating temporary working directory..."
rm -rf /tmp/proton-ge-custom
mkdir /tmp/proton-ge-custom
cd /tmp/proton-ge-custom
# fetch latest releases
echo "Fetching latest relases"
tags=$(curl -s "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases?per_page=5" | jq -r '.[].tag_name')
tags_version=$(echo "$tags" | sed -E 's/.*Proton([0-9]+)-([0-9]+)$/\1-\2/')
echo "Release tags:"
echo "$tags_version"
echo "Pick a version or enter nothing for the latest"
read picked_tag
if [ -z "$picked_tag"]; then
    picked_tag=$(echo "$tags_version" | sort -V | tail -n 1)
fi
# download tarball
echo "Fetching tarball URL..."
tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/tags/GE-Proton$picked_tag | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
tarball_name=$(basename $tarball_url)
echo "Downloading tarball: $tarball_name..."
curl -# -L $tarball_url -o $tarball_name

# download checksum
echo "Fetching checksum URL..."
checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/tags/GE-Proton$picked_tag | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
checksum_name=$(basename $checksum_url)
echo "Downloading checksum: $checksum_name..."
curl -# -L $checksum_url -o $checksum_name

# check tarball with checksum
echo "Verifying tarball $tarball_name with checksum $checksum_name..."
sha512sum -c $checksum_name
# if result is ok, continue

# make steam directory if it does not exist
echo "Creating Steam directory if it does not exist..."
mkdir -p ~/.steam/root/compatibilitytools.d

# extract proton tarball to steam directory
echo "Extracting $tarball_name to Steam directory..."
tar -xf $tarball_name -C ~/.steam/root/compatibilitytools.d/
echo "All done :)"

