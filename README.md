# Anytype MCP for Unraid

Runs [anytype-cli](https://github.com/anyproto/anytype-cli) and exposes Anytype tools as an OpenAPI server for Open WebUI.

## 1. Set Up Unraid Container

Container runs as Unraid's `nobody:users` user (UID/GID `99:100`). Create persistent directory:

```sh
mkdir -p /mnt/user/appdata/anytype-mcp
chown -R 99:100 /mnt/user/appdata/anytype-mcp
```

Create bot account in Unraid terminal. Save printed bot account key securely.

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

Create Anytype API key. Copy printed key for next step.

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

Generate proxy key:

```sh
openssl rand -hex 32
```

In Unraid **Docker** > **Add Container**, set:

| Field | Value |
| --- | --- |
| Name | `anytype-mcp` |
| Repository | `ghcr.io/basketkase/anytype-cli-docker:main` |
| Network Type | `bridge` |
| Port | Host `8000` to container `8000` (TCP) |
| Path | Host `/mnt/user/appdata/anytype-mcp` to container `/data` |
| Variable | `OPENAPI_MCP_HEADERS` = `{"Authorization":"Bearer YOUR_ANYTYPE_API_KEY","Anytype-Version":"2025-11-08"}` |
| Variable | `MCPO_API_KEY` = generated proxy key |

Click **Apply**. Keep port `8000` on trusted network only; it grants access to Anytype through provided API key.

## 2. Connect Bot to Space

In Anytype desktop, create invite link for target space and grant bot **Editor** access. With container running:

```sh
docker exec -it anytype-mcp anytype space join 'PASTE_ANYTYPE_INVITE_LINK'
```

Replace `anytype-mcp` with Unraid container name. Verify access:

```sh
docker exec -it anytype-mcp anytype space list
```

## 3. Connect Open WebUI

In Open WebUI, add an **OpenAPI** server:

| Field | Value |
| --- | --- |
| Server URL | `http://UNRAID-IP:8000/openapi.json` |
| Header | `Authorization: Bearer MCPO_API_KEY` |

Use actual proxy key from `MCPO_API_KEY`. Select **OpenAPI**, not **MCP (Streamable HTTP)**: `mcpo` converts Anytype's stdio MCP server to OpenAPI HTTP.
