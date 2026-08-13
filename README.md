# Anytype CLI Docker

Runs [anytype-cli](https://github.com/anyproto/anytype-cli) and exposes its MCP tools as an OpenAPI server for Open WebUI.

```sh
docker run --rm -it -v anytype-data:/data --entrypoint anytype ghcr.io/OWNER/anytype-cli-docker:main auth create bot
```

Start server after creating Anytype API key:

```sh
docker run --rm -p 8000:8000 -v anytype-data:/data \
  -e OPENAPI_MCP_HEADERS='{"Authorization":"Bearer YOUR_ANYTYPE_API_KEY","Anytype-Version":"2025-11-08"}' \
  -e MCPO_API_KEY='choose-a-long-random-secret' \
  ghcr.io/basketkase/anytype-cli-docker:main
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
