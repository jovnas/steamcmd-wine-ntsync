#!/bin/bash
set -euxo pipefail

MONO_VER="11.3.0"
MONO_SHA256="df2dfc1665c2511882e7cabd56eafd0c0a3d94e5a7e86f969277f6c189d418d3"
WINE_VER="11.21"
WINE_TYPE="${WINE_TYPE:-staging-tkg-amd64-wow64}"

# Install the setup tools, fonts, and libraries used directly by Wine and its backends.
# APT resolves their transitive dependencies.
apt-get update
apt-get upgrade --yes
apt-get install -y --no-install-recommends \
    ca-certificates cabextract curl file locales openssl patch tar unzip wget xz-utils \
    xauth xvfb xfonts-base \
    fonts-croscore fonts-dejavu-core fonts-dejavu-mono fonts-freefont-otf \
    fonts-freefont-ttf fonts-liberation fonts-noto-core fonts-noto-mono \
    fonts-texgyre fonts-urw-base35 \
    libasound2t64 libcapi20-3t64 libcups2t64 libdbus-1-3 libegl1 libegl-mesa0 \
    libfontconfig1 libfreetype6 libgl1 libgl1-mesa-dri libglu1-mesa libglx-mesa0 \
    libgnutls30t64 libgphoto2-6t64 libgsm1 libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 libjpeg8 libmpg123-0t64 libncurses6 libodbccr2 libodbc2 \
    libosmesa6 libpcap0.8t64 libpcsclite1 libpng16-16t64 libpulse0 \
    libsane1 libsdl2-2.0-0 libstdc++6 libudev1 libusb-1.0-0 libv4l-0t64 \
    libvulkan1 libwayland-client0 libwayland-cursor0 libwayland-egl1 libx11-6 \
    libxcomposite1 libxcursor1 libxext6 libxfixes3 libxi6 libxinerama1 \
    libxkbcommon0 libxkbregistry0 libxml2-16 libxrandr2 libxrender1 libxslt1.1 \
    libxxf86vm1 libz-mingw-w64 mesa-vulkan-drivers ocl-icd-libopencl1 \
    openssl-provider-legacy
rm -rf /var/lib/apt/lists/*

echo "Downloading and extracting Wine..."
mkdir -p "$HOME/wine"
wget -qO- "https://github.com/Kron4ek/Wine-Builds/releases/download/${WINE_VER}/wine-${WINE_VER}-${WINE_TYPE}.tar.xz" \
    | tar -xJ -C "$HOME/wine" --strip-components=1

echo -e "Installing Wine-Mono..."
mono_msi="$HOME/wine/share/wine/mono/wine-mono-${MONO_VER}-x86.msi"
mkdir -p "${mono_msi%/*}"
# Retry interrupted transfers and avoid HTTP/2 framing errors on this download.
curl -fsSL --http1.1 --retry 3 --retry-all-errors --max-time 120 -o "$mono_msi" \
    "https://github.com/wine-mono/wine-mono/releases/download/wine-mono-${MONO_VER}/wine-mono-${MONO_VER}-x86.msi"
printf '%s  %s\n' "$MONO_SHA256" "$mono_msi" | sha256sum --check

echo -e "Installing Winetricks..."
wget https://raw.githubusercontent.com/Winetricks/winetricks/f3890f670867b5ffbc3938726db45c0f7d16c8ba/src/winetricks
# Pin the Microsoft installers and reject checksum mismatches in quiet builds.
patch --batch --forward --fuzz=0 winetricks /winetricks-vcrun2026.patch
apt-get purge -y patch
chmod +x winetricks
mv winetricks /usr/local/bin/
