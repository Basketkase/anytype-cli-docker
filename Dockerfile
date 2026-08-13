FROM alpine:3.23

ARG ANYTYPE_VERSION=v0.3.6
ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl tar \
    && curl -fsSL "https://github.com/anyproto/anytype-cli/releases/download/${ANYTYPE_VERSION}/anytype-cli-${ANYTYPE_VERSION}-linux-${TARGETARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin anytype \
    && adduser -D -h /data anytype

USER anytype
WORKDIR /data

EXPOSE 31012
VOLUME ["/data"]

ENTRYPOINT ["anytype"]
CMD ["serve", "--listen-address", "0.0.0.0:31012"]
