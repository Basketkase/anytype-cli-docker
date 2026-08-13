FROM python:3.12-alpine

ARG ANYTYPE_MCP_VERSION=1.2.10

RUN apk add --no-cache nodejs npm \
    && pip install --no-cache-dir mcpo \
    && npm install --global "@anyproto/anytype-mcp@${ANYTYPE_MCP_VERSION}"

EXPOSE 8000

ENTRYPOINT ["mcpo"]
CMD ["--host", "0.0.0.0", "--port", "8000", "--", "anytype-mcp"]
