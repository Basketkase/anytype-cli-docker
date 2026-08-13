# Anytype CLI Docker

Runs [anytype-cli](https://github.com/anyproto/anytype-cli) and exposes its MCP tools as an OpenAPI server for Open WebUI.

```sh
docker run --rm -it -v anytype-data:/data --entrypoint sh ghcr.io/OWNER/anytype-cli-docker:main -c '
  anytype serve --listen-address 127.0.0.1:31012 &
  sleep 5
  anytype auth create bot
'
```

Start server after creating Anytype API key:

```sh
docker run --rm -p 8000:8000 -v anytype-data:/data \
  -e OPENAPI_MCP_HEADERS='{"Authorization":"Bearer YOUR_ANYTYPE_API_KEY","Anytype-Version":"2025-11-08"}' \
  -e MCPO_API_KEY='choose-a-long-random-secret' \
  ghcr.io/basketkase/anytype-cli-docker:main
```

Create API key after bot account exists:

```sh
docker run --rm -it -v anytype-data:/data --entrypoint sh ghcr.io/OWNER/anytype-cli-docker:main -c '
  anytype serve --listen-address 127.0.0.1:31012 &
  sleep 5
  anytype auth apikey create open-webui
'
```

## Open WebUI

Anytype listens only inside container. `mcpo` converts its stdio MCP server into an OpenAPI HTTP server on port `8000`.

Use `compose.yml` instead:

```sh
export OPENAPI_MCP_HEADERS='{"Authorization":"Bearer YOUR_ANYTYPE_API_KEY","Anytype-Version":"2025-11-08"}'
export MCPO_API_KEY='choose-a-long-random-secret'
docker compose up -d
```

In Open WebUI, add an **OpenAPI** server at `http://HOST:8000/openapi.json` with header `Authorization: Bearer MCPO_API_KEY`. Do not use Open WebUI's **MCP (Streamable HTTP)** connection type: `mcpo` exposes OpenAPI, not Streamable HTTP.

Keep port `8000` on trusted network only. It grants access to Anytype through provided API key.

## Unraid

Container runs as Unraid's `nobody:users` user (UID/GID `99:100`). If directory was created with different ownership, fix it:

```sh
mkdir -p /mnt/user/appdata/anytype-mcp
chown -R 99:100 /mnt/user/appdata/anytype-mcp
```

In **Docker** > **Add Container**, set:

| Field | Value |
| --- | --- |
| Name | `anytype-mcp` |
| Repository | `ghcr.io/basketkase/anytype-cli-docker:main` |
| Network Type | `bridge` |
| Port | Host `8000` to container `8000` (TCP) |
| Path | Host `/mnt/user/appdata/anytype-mcp` to container `/data` |
| Variable | `OPENAPI_MCP_HEADERS` = `{"Authorization":"Bearer YOUR_ANYTYPE_API_KEY","Anytype-Version":"2025-11-08"}` |
| Variable | `MCPO_API_KEY` = long random secret |

Click **Apply**. In Open WebUI, add an **OpenAPI** server at `http://UNRAID-IP:8000/openapi.json` with `Authorization: Bearer MCPO_API_KEY` header.

Create bot account before starting container. In Unraid terminal:

```sh
docker run --rm -it \
  -v /mnt/user/appdata/anytype-mcp:/data \
  --entrypoint sh \
  ghcr.io/basketkase/anytype-cli-docker:main -c '
    anytype serve --listen-address 127.0.0.1:31012 &
    sleep 5
    anytype auth create bot
  '
```

Create API key with same volume, then copy printed key into `OPENAPI_MCP_HEADERS`:

```sh
docker run --rm -it \
  -v /mnt/user/appdata/anytype-mcp:/data \
  --entrypoint sh \
  ghcr.io/basketkase/anytype-cli-docker:main -c '
    anytype serve --listen-address 127.0.0.1:31012 &
    sleep 5
    anytype auth apikey create open-webui
  '
```
