# Anytype CLI Docker Image

Runs [anytype-cli](https://github.com/anyproto/anytype-cli) in a minimal image. Data is stored in `/data`; the container runs as Unraid's `nobody:users` user (UID/GID `99:100`).

```sh
mkdir -p /mnt/user/appdata/anytype-cli
chown -R 99:100 /mnt/user/appdata/anytype-cli

docker run --rm -it \
  -v /mnt/user/appdata/anytype-cli:/data \
  ghcr.io/basketkase/anytype-cli-docker:main --help
```

Pass any [Anytype CLI command](https://github.com/anyproto/anytype-cli) after the image name. For example:

```sh
docker run --rm -it \
  -v /mnt/user/appdata/anytype-cli:/data \
  ghcr.io/basketkase/anytype-cli-docker:main space list
```
