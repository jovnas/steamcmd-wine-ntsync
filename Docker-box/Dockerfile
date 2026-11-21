FROM ubuntu:26.04

ARG DEBIAN_FRONTEND="noninteractive"
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}
ARG RUNX64="box64"
ENV runx64=${RUNX64}

# Install Wine, its host dependencies, and Winetricks.
ARG WINE_TYPE=staging-tkg-amd64-wow64
RUN --mount=type=bind,source=install-wine.sh,target=/install-wine.sh \
    --mount=type=bind,source=winetricks-vcrun2026.patch,target=/winetricks-vcrun2026.patch \
    bash /install-wine.sh \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win64

# Install Box64 and set up the Wine launchers.
RUN --mount=type=bind,source=install-box.sh,target=/install-box.sh \
    --mount=type=bind,source=wrap-wine.sh,target=/wrap-wine.sh \
    bash /install-box.sh && bash /wrap-wine.sh

# Suppress Wine debug messages
ENV WINEDEBUG=-all
ENV BOX64_LOG=0

# Configure xvfb
ENV DISPLAY=:0
ENV XDG_DATA_DIRS=/root/wine/share:/usr/local/share:/usr/share
ENV XDG_RUNTIME_DIR=/run/user/0
# Allow testing Wine prefix setup with Box64's interpreter on ARM64.
ARG WINE_SETUP_BOX64_DYNAREC=1
RUN install -d -m 700 "$XDG_RUNTIME_DIR" \
 && BOX64_LOG=1 BOX64_DYNAREC="$WINE_SETUP_BOX64_DYNAREC" xvfb-run winetricks -q vcrun2026 \
 && rm -rf /root/.cache/winetricks /tmp/* /var/tmp/*

###Steam block
RUN --mount=type=bind,source=init-steam.sh,target=/init-steam.sh \
    bash /init-steam.sh && rm -rf /tmp/* /var/tmp/*

WORKDIR /root

COPY benchmarks/ ./benchmarks/

# Set default command
ENTRYPOINT ["steamcmd"]
CMD ["+help", "+quit"]
