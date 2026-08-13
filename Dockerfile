FROM python:3.12-alpine

ARG ANYTYPE_VERSION=v0.3.6
ARG ANYTYPE_MCP_VERSION=1.2.10
ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl netcat-openbsd nodejs npm tar \
    && curl -fsSL "https://github.com/anyproto/anytype-cli/releases/download/${ANYTYPE_VERSION}/anytype-cli-${ANYTYPE_VERSION}-linux-${TARGETARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin anytype \
    && pip install --no-cache-dir mcpo \
    && npm install --global "@anyproto/anytype-mcp@${ANYTYPE_MCP_VERSION}" \
    && adduser -D -u 1000 -h /data anytype

USER anytype
WORKDIR /data
ENV ANYTYPE_API_BASE_URL=http://127.0.0.1:31012

EXPOSE 8000
VOLUME ["/data"]

COPY --chown=anytype:anytype --chmod=755 start.sh /usr/local/bin/start
ENTRYPOINT ["start"]
