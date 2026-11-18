#!/bin/bash
set -euxo pipefail

if [ "$TARGETARCH" = "amd64" ]; then
    echo "Skipping Box64 install on amd64"
    exit 0
fi

# The generic ARM64 package includes Box32 for SteamCMD's 32-bit launcher.
BOX64_VERSION="0.4.5+20261117.27c8275-1"
BOX64_DEBS_REVISION="d965e3c1bf115723ccdfed62cf7a5b53a0de4ed8"
BOX64_SHA256="d8a21a5d4e4b30b7cf23568e96c30c93f4b393f9153f1a7b8d6b85580f5251f5"
package=$(mktemp --suffix=.deb)
trap 'rm -f "$package"' EXIT

curl -fsSL "https://raw.githubusercontent.com/ryanfortner/box64-debs/${BOX64_DEBS_REVISION}/debian/box64_${BOX64_VERSION}_arm64.deb" -o "$package"
printf '%s  %s\n' "$BOX64_SHA256" "$package" | sha256sum --check
dpkg -i "$package"
