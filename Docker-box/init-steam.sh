#!/usr/bin/env bash
set -euo pipefail

if [ "$TARGETARCH" = "arm64" ]; then
    # Ubuntu 26.04 serves arm64 on the main archive and armhf on Ubuntu Ports.
    sed -i '/^Types: deb$/a Architectures-Remove: armhf' /etc/apt/sources.list.d/ubuntu.sources
    . /etc/os-release
    cat >/etc/apt/sources.list.d/ubuntu-armhf.sources <<EOF
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: ${VERSION_CODENAME} ${VERSION_CODENAME}-updates ${VERSION_CODENAME}-security ${VERSION_CODENAME}-backports
Components: main universe restricted multiverse
Architectures: armhf
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    dpkg --add-architecture armhf
    apt-get update
    apt-get install -y libc6:armhf libpthread-stubs0-dev:armhf libncurses6:armhf libstdc++6:armhf
elif [ "$TARGETARCH" = "amd64" ]; then
    dpkg --add-architecture i386
    apt-get update
    apt-get install -y libc6:i386 libpthread-stubs0-dev:i386 lib32gcc-s1 lib32stdc++6 lib32z1 libncurses6:i386
fi


steamcmd_dir="$HOME/steamcmd"
mkdir -p "$steamcmd_dir"

curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
  | tar -xz -C "$steamcmd_dir"
chmod +x "$steamcmd_dir/steamcmd.sh"

cat <<EOF >/usr/local/bin/steamcmd
#!/bin/bash
if [ -n "\${runx64:-}" ]; then
    # Keep the x86 launcher selected even when SteamCMD restarts after an update.
    export STEAM_PLATFORM=linux32
    # Valve's launcher uses DEBUGGER to prefix the 32-bit SteamCMD binary.
    export DEBUGGER="\$runx64"
fi
exec "$steamcmd_dir/steamcmd.sh" "\$@"
EOF

chmod +x /usr/local/bin/steamcmd
ln -sf /usr/local/bin/steamcmd /usr/local/bin/steamcmd.sh

# Run SteamCMD once to allow it to self-update and create folders
steamcmd +quit

mkdir -p ~/.steam
chmod -R 777 ~/.steam
ln -sf "$steamcmd_dir/linux32" ~/.steam/sdk32
ln -sf "$steamcmd_dir/linux64" ~/.steam/sdk64

ln -sf ~/.steam/sdk32/steamclient.so ~/.steam/sdk32/steamservice.so
ln -sf ~/.steam/sdk64/steamclient.so ~/.steam/sdk64/steamservice.so
