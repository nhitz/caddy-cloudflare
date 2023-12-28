FROM --platform=$BUILDPLATFORM caddy:builder-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    GOOS=$TARGETOS GOARCH=$TARGETARCH xcaddy build --with github.com/caddy-dns/cloudflare

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
