WINE_VER="11.22"

docker manifest create --amend "tsxcloud/steamcmd-wine-ntsync:${WINE_VER}" \
  tsxcloud/steamcmd-wine-ntsync:${WINE_VER}-arm64-box \
  tsxcloud/steamcmd-wine-ntsync:${WINE_VER}-amd64

docker manifest push --purge "tsxcloud/steamcmd-wine-ntsync:${WINE_VER}"

docker manifest create --amend "tsxcloud/steamcmd-wine-ntsync:latest" \
  tsxcloud/steamcmd-wine-ntsync:${WINE_VER}-amd64 \
  tsxcloud/steamcmd-wine-ntsync:${WINE_VER}-arm64-box

docker manifest push --purge "tsxcloud/steamcmd-wine-ntsync:latest"
