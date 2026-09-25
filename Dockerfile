FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY . .

RUN apk add --no-cache git make nodejs npm && \
    make build

FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata curl bash iptables ip6tables && \
    curl -Lo /usr/local/bin/warp-plus https://github.com/bepass-org/warp-plus/releases/latest/download/warp-plus_linux_amd64 && \
    chmod +x /usr/local/bin/warp-plus

COPY --from=builder /app/bin/x-ui /app/x-ui
COPY --from=builder /app/bin/xray-linux-* /app/bin/
COPY DockerEntrypoint.sh /app/DockerEntrypoint.sh

RUN chmod +x /app/DockerEntrypoint.sh

VOLUME [ "/etc/x-ui" ]

EXPOSE 2053

ENTRYPOINT [ "/app/DockerEntrypoint.sh" ]
