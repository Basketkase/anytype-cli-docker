# Anytype CLI Docker Image

Runs [anytype-cli](https://github.com/anyproto/anytype-cli) in a minimal image. Data is stored in `/data`; the container runs as Unraid's `nobody:users` user (UID/GID `99:100`).

## Initial Unraid Setup

Create a persistent data directory in the Unraid terminal:

```sh
mkdir -p /mnt/user/appdata/anytype-cli
chown -R 99:100 /mnt/user/appdata/anytype-cli
```

In Unraid **Docker** > **Add Container**, use:

| Field | Value |
| --- | --- |
| Name | `anytype-cli` |
| Repository | `ghcr.io/basketkase/anytype-cli-docker:main` |
| Network Type | `bridge` |
| Port | Host `31012` to container `31012` (TCP) |
| Path | Host `/mnt/user/appdata/anytype-cli` to container `/data` |

Leave **Command** blank: the image starts `anytype serve` and makes its API available on port `31012`. No environment variables are required. Keep this port on a trusted network only; applications need the API key created below to access Anytype. Start the container, then create a bot account from the Unraid terminal. Store the printed bot account key securely.

```sh
docker exec -it anytype-cli anytype auth create bot --listen-address 0.0.0.0:31012
```

Create an API key for applications that will access the local Anytype API. Store the printed key securely.

```sh
docker exec -it anytype-cli anytype auth apikey create unraid
```

Other services can call `http://UNRAID_HOST:31012` with that key. Include the `Authorization: Bearer YOUR_ANYTYPE_API_KEY` and `Anytype-Version: 2025-11-08` headers.

In Anytype desktop, create an invite link for the target space and grant the bot **Editor** access. Join that space and confirm access:

```sh
docker exec -it anytype-cli anytype space join 'PASTE_ANYTYPE_INVITE_LINK'
docker exec -it anytype-cli anytype space list
```

## Run Commands

With the service container running, use `docker exec` for CLI commands:

```sh
docker exec -it anytype-cli anytype space list
```

For one-off commands, run the image directly with the same data directory:

```sh
docker run --rm -it \
  -v /mnt/user/appdata/anytype-cli:/data \
  --entrypoint anytype \
  ghcr.io/basketkase/anytype-cli-docker:main --help
```
