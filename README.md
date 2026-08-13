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

## 3. Expose Through Traefik

Open WebUI loaded over HTTPS cannot fetch an HTTP OpenAPI server, and its browser requests require CORS. Put this container and Traefik on the same Docker network, then add these labels to the Anytype container. Replace the hostnames, Docker network, and certificate resolver.

```yaml
labels:
  - traefik.enable=true
  - traefik.docker.network=proxy
  - traefik.http.routers.anytype-mcp.rule=Host(`anytype-mcp.example.com`)
  - traefik.http.routers.anytype-mcp.entrypoints=websecure
  - traefik.http.routers.anytype-mcp.tls.certresolver=letsencrypt
  - traefik.http.services.anytype-mcp.loadbalancer.server.port=8000
  - traefik.http.routers.anytype-mcp.middlewares=anytype-mcp-cors
  - traefik.http.middlewares.anytype-mcp-cors.headers.accesscontrolalloworiginlist=https://open-webui.example.com
  - traefik.http.middlewares.anytype-mcp-cors.headers.accesscontrolallowmethods=GET,POST,PUT,PATCH,DELETE,OPTIONS
  - traefik.http.middlewares.anytype-mcp-cors.headers.accesscontrolallowheaders=Authorization,Content-Type,X-Session-Id
```

Use the exact browser origin for `accesscontrolalloworiginlist`, including a non-default port when applicable. If the browser reports another missing CORS header, add its `Access-Control-Request-Headers` value to `accesscontrolallowheaders`.

## 4. Connect Open WebUI

In Open WebUI, add an **OpenAPI** server:

| Field | Value |
| --- | --- |
| URL | `https://anytype-mcp.example.com` |
| Auth | `Bearer` |
| Token | raw `MCPO_API_KEY` value, without `Bearer ` |
| OpenAPI Spec | URL: `openapi.json` |

Open WebUI resolves this to `https://anytype-mcp.example.com/openapi.json`. Select **OpenAPI**, not **MCP (Streamable HTTP)**: `mcpo` converts Anytype's stdio MCP server to OpenAPI HTTP.
