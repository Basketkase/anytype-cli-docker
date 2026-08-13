#!/bin/sh
set -eu

: "${OPENAPI_MCP_HEADERS:?Set the Anytype API key header}"
: "${MCPO_API_KEY:?Set the MCP proxy API key}"

anytype serve --listen-address 127.0.0.1:31012 &
anytype_pid=$!

until nc -z 127.0.0.1 31010; do
    if ! kill -0 "$anytype_pid" 2>/dev/null; then
        wait "$anytype_pid"
        exit $?
    fi
    sleep 1
done

mcpo --host 0.0.0.0 --port 8000 --api-key "$MCPO_API_KEY" -- anytype-mcp &
mcpo_pid=$!

trap 'kill -TERM "$mcpo_pid" "$anytype_pid" 2>/dev/null; wait "$mcpo_pid" || true; wait "$anytype_pid" || true; exit' INT TERM
wait "$mcpo_pid"
