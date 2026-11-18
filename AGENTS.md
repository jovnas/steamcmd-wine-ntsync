# Repository Guidelines

## Project Structure

Each image variant has its own Docker build context. `Docker-box/` builds the Box64 image on ARM64 and the native image on AMD64. `Docker-fex/` and `Docker-hangover/` build the FEX and Hangover variants for ARM64. Each directory contains a `Dockerfile`, Bash scripts for installing Wine and emulator dependencies, and `init-steam.sh` for SteamCMD setup. Benchmark launchers live in each variant's `benchmarks/` directory. See `README.md` for published tags and runtime examples.

## Build and Run

- Run `(cd Docker-box && bash build.sh)` to build the image for the host architecture.
- On ARM64, run `(cd Docker-fex && bash build.sh)` or `(cd Docker-hangover && bash build.sh)` to build the corresponding variant.
- Run `docker run --rm <image-tag> +help +quit` with the image tag specified in the variant’s `build.sh` to smoke-test the SteamCMD entrypoint. Use `docker run --rm -it --entrypoint bash <image-tag>` to inspect Wine or the emulator interactively.

## Shell and Dockerfile Style

Use Bash for shell scripts, keep the existing shebang, and match indentation in the file you edit. Build and setup scripts typically use four spaces within conditionals. Use lowercase, hyphenated script names such as `install-wine.sh`. Preserve case-sensitive variables used across the Dockerfile and scripts, including `TARGETARCH`, `WINEPREFIX`, and `runx64`. Check parallel scripts in the other variants when changing shared setup behavior.

## Testing

Run `bash -n path/to/script.sh` on each edited shell script. The repository has no automated test suite or coverage target. Build and smoke-test each affected image on its supported architecture. For emulation performance changes, run `bash download_and_run_benchmarks.sh` from the image's benchmark directory. The launcher downloads the benchmark from GitHub.

## Commits and Pull Requests

Keep commit subjects short and specific. Recent history includes `Update WINE_TYPE variable in install-wine.sh` and version updates such as `up to 10.17`. In the pull request, describe the change, identify affected variants and architectures, report build and smoke-test results, and link any related issue.
