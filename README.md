# Anytype CLI Docker

Runs [anytype-cli](https://github.com/anyproto/anytype-cli) server in a persistent Docker volume.

```sh
docker run --rm -p 31012:31012 -v anytype-data:/data ghcr.io/OWNER/anytype-cli-docker:main
```

Create bot account, join space, and create API key from another shell:

```sh
docker run --rm -it -v anytype-data:/data --entrypoint anytype ghcr.io/OWNER/anytype-cli-docker:main auth create bot
```

API listens at `http://localhost:31012`. Workflow builds `linux/amd64` and `linux/arm64`, publishing branch, tag, and commit-SHA images to GitHub Container Registry.

## Open WebUI

Anytype MCP uses stdio. Open WebUI only accepts Streamable HTTP MCP, so direct connection is not possible. `compose.yml` runs `mcpo`, which converts Anytype MCP into an OpenAPI HTTP server.

Set keys and start both containers:

```sh
export OPENAPI_MCP_HEADERS='{"Authorization":"Bearer YOUR_ANYTYPE_API_KEY","Anytype-Version":"2025-11-08"}'
export MCPO_API_KEY='choose-a-long-random-secret'
docker compose up -d
```

In Open WebUI, add an **OpenAPI** server at `http://HOST:8000/openapi.json` with header `Authorization: Bearer MCPO_API_KEY`. If Open WebUI runs in same Compose project, use `http://anytype-mcp:8000/openapi.json`. Do not use Open WebUI's **MCP (Streamable HTTP)** connection type: `mcpo` exposes OpenAPI, not Streamable HTTP.

Keep port `8000` on trusted network only. It grants access to Anytype through provided API key.
