FROM golang:1.23-bookworm AS builder

ARG TARGETARCH
ENV CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH GO111MODULE=on

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc-dev \
    gcc-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /dist

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    if [ "$TARGETARCH" = "arm64" ]; then \
        CC=aarch64-linux-gnu-gcc go build -o manager ; \
    else \
        go build -o manager ; \
    fi

FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /dist/manager .

USER 65532:65532

ENTRYPOINT ["/manager"]
