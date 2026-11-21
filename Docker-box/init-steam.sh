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
    apt-get install -y --no-install-recommends libc6:armhf libncurses6:armhf libstdc++6:armhf
elif [ "$TARGETARCH" = "amd64" ]; then
    dpkg --add-architecture i386
    apt-get update
    # Use the i386 multiarch directory for all 32-bit libraries.
    apt-get install -y --no-install-recommends \
        libc6:i386 libncurses6:i386 libstdc++6:i386 zlib1g:i386
fi
rm -rf /var/lib/apt/lists/*

steamcmd_dir="$HOME/steamcmd"
mkdir -p "$steamcmd_dir"

curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
  | tar -xz -C "$steamcmd_dir"
chmod +x "$steamcmd_dir/steamcmd.sh"

cat <<EOF >/usr/local/bin/steamcmd
#!/bin/bash
if [ -n "\${runx64:-}" ]; then
    export STEAM_PLATFORM=linux32
    # The bootstrap archive only contains linux32. Use linux64 after self-update.
    if [ -x "$steamcmd_dir/linux64/steamcmd" ]; then
        export STEAM_PLATFORM=linux64
    fi
    # Valve's launcher uses DEBUGGER to prefix the selected SteamCMD binary.
    export DEBUGGER="\$runx64"
fi
exec "$steamcmd_dir/steamcmd.sh" "\$@"
EOF

chmod +x /usr/local/bin/steamcmd
ln -sf /usr/local/bin/steamcmd /usr/local/bin/steamcmd.sh

# The initial run can fail after extraction when the updater restarts under Box32.
steamcmd +quit || echo "SteamCMD exited during bootstrap. Checking the installed files." >&2
if [ ! -x "$steamcmd_dir/linux64/steamcmd" ] || [ ! -s "$steamcmd_dir/linux32/steamclient.so" ] || [ ! -s "$steamcmd_dir/linux64/steamclient.so" ]; then
    echo "SteamCMD bootstrap failed before both SDK libraries were installed. Build filesystem space:" >&2
    df -h "$steamcmd_dir" /tmp >&2
    exit 1
fi

# SteamCMD can exit zero even when Steam API initialization fails.
if ! steamcmd_help=$(steamcmd +help +quit 2>&1) || [[ "$steamcmd_help" != *$'Usage:\tsteamcmd '* ]]; then
    printf '%s\n' "$steamcmd_help" >&2
    echo "SteamCMD failed to initialize and print command help." >&2
    exit 1
fi
printf '%s\n' "$steamcmd_help"

mkdir -p ~/.steam
chmod -R 777 ~/.steam
ln -sf "$steamcmd_dir/linux32" ~/.steam/sdk32
ln -sf "$steamcmd_dir/linux64" ~/.steam/sdk64

ln -sf ~/.steam/sdk32/steamclient.so ~/.steam/sdk32/steamservice.so
ln -sf ~/.steam/sdk64/steamclient.so ~/.steam/sdk64/steamservice.so
