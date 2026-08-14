FROM alpine:3.22

ARG ANYTYPE_VERSION=v0.3.6
ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl tar \
    && curl -fsSL "https://github.com/anyproto/anytype-cli/releases/download/${ANYTYPE_VERSION}/anytype-cli-${ANYTYPE_VERSION}-linux-${TARGETARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin anytype \
    && mkdir -p /data \
    && chown 99:100 /data

USER 99:100
WORKDIR /data
ENV HOME=/data

EXPOSE 31012
VOLUME ["/data"]

ENTRYPOINT ["anytype", "serve", "--listen-address", "0.0.0.0:31012"]
