## Base information
The current Box64 build uses Ubuntu 26.04, Wine 11.22, and a pinned prebuilt Box64 0.4.5 snapshot with Box32 support. Its Wine build includes staging, TKG, NTSync, and WoW64. Additionally, Wine Mono and the Visual C++ 2026 Redistributable are preinstalled.

This Docker build is designed to be compatible with https://hub.docker.com/r/steamcmd/steamcmd

## ARM64
ARM64 compatibility is provided by Box64/Fex-emu/Hangover

## Building the Box64 image on a Raspberry Pi 5

On a Pi 5 running a 64-bit OS, build from this checkout and check that SteamCMD starts.

```bash
(cd Docker-box && bash build.sh)
docker run --rm tsxcloud/steamcmd-wine-ntsync:11.22-arm64-box +help +quit
```

Use the local `tsxcloud/steamcmd-wine-ntsync:11.22-arm64-box` tag in your Valheim service's `image:` setting. Keep your existing world volumes and server configuration. Check the server logs for successful startup, then verify that a client can join.

## DockerHUB
https://hub.docker.com/r/tsxcloud/steamcmd-wine-ntsync

## Usage
Pull latest image
```yaml
docker pull tsxcloud/steamcmd-wine-ntsync:latest
```
Test interactively
```yaml
docker run --entrypoint bash -it tsxcloud/steamcmd-wine-ntsync:latest
```
* To run SteamCMD:

  ```bash
  steamcmd
  ```

* To run x86\_64 Linux programs:

  ```bash
  $runx64 ./your_x64_program
  ```

* To run x86\_64 Windows programs:

  ```bash
  wine your_x64_program.exe
  ```

An example of usage can be seen with the game LOTR Moria. https://github.com/tsx-cloud/moria-docker-arm

---

## Running a Game Server or App on ARM with Docker

If you want to run a **playful server or Windows program on ARM**, follow this step-by-step approach:

### 1. Start with the default image

```bash
tsxcloud/steamcmd-wine-ntsync:latest
```

### 2. If that doesn't work, try the FEX variant

```bash
tsxcloud/steamcmd-wine-ntsync:arm64-fex
```

### 3. Still no luck? Try with Hangover

```bash
tsxcloud/steamcmd-wine-ntsync:arm64-hangover
```

### 4. Nothing works? Back to step 1 — but with tweaks

Switch back to:

```bash
tsxcloud/steamcmd-wine-ntsync:latest
```

And experiment with Box64 environment variables. See [Box64 Usage Docs](https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md) for full options.

#### Example in a bash script:

```bash
export BOX64_DYNAREC_STRONGMEM=1
```

---

### 🔧 How to set environment variables in `docker-compose.yml`

```yaml
services:
  game-server:
    image: tsxcloud/steamcmd-wine-ntsync:latest
    environment:
      - BOX64_DYNAREC_STRONGMEM=1
      - BOX64_LOG=1
```

---

This tiered approach gives you a fallback at every step — and lets you squeeze every bit of compatibility out of your ARM system.

##
Enjoying the project? A ⭐ goes a long way!
