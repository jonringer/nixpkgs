#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl jq common-updater-scripts nix

set -eu -o pipefail

MINECRAFT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
sources=sources.json

linux_manifest=$(curl -s 'https://launchermeta.mojang.com/v1/products/launcher/6f083b80d5e6fabbc4236f81d0d8f8a350c665a9/linux.json')
version=$(echo $linux_manifest | jq -r '."launcher-core"[0].version.name')

core_manifest=$(curl -s $(echo $linux_manifest | jq -r '."launcher-core"[0].manifest.url'))

update-source-version minecraft "${version}"

rm -f ${MINECRAFT_DIR}/sources.json

echo "{" > $sources

for lib in "libcef.so" "libgconf-2.so.4" "liblauncher.so"; do
    url=$(echo $core_manifest | jq -r '.files."'${lib}'".downloads.raw.url')
    sha256=$(nix-prefetch-url ${url})
    echo "  \"${lib}\" : {" >> $sources
    echo "    \"url\": \"${url}\"" >> $sources
    echo "    \"sha256\": \"${sha256}\"" >> $sources
    echo "  }," >> $sources
done
