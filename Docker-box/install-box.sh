#!/bin/bash
set -euxo pipefail

if [ "$TARGETARCH" = "amd64" ]; then
    echo "Skipping Box64 install on amd64"
    exit 0
fi

BOX64_VERSION="v0.4.4"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

apt-get install -y cmake
git clone --depth 1 --branch "$BOX64_VERSION" https://github.com/ptitSeb/box64.git "$build_dir/src"
# SteamCMD needs Box32 for its 32-bit Linux launcher.
cmake -S "$build_dir/src" -B "$build_dir/build" -DARM64=ON -DBOX32=ON -DCMAKE_BUILD_TYPE=Release
cmake --build "$build_dir/build" --parallel 2
cmake --install "$build_dir/build"
