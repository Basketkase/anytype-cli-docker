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
