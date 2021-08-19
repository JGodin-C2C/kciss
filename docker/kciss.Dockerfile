ARG TRIVY_VERSION=0.19.2
ARG ALPINE_VERSION=3.14.0

FROM ghcr.io/aquasecurity/trivy:$TRIVY_VERSION as trivy

FROM golang:1.16 as builder
WORKDIR /go/src/github.com/fabricev/kciss/cmd
COPY go.* /go/src/github.com/fabricev/kciss/
RUN go mod download
COPY cmd/ /go/src/github.com/fabricev/kciss/cmd/
RUN --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 GOOS=linux go build -o ../kciss

FROM alpine:$ALPINE_VERSION
ARG UID="2000"
ARG GID="2000"
LABEL org.opencontainers.image.source https://github.com/fabricev/kciss
RUN apk --no-cache add ca-certificates=20191127-r5 && \
    addgroup -g "$GID" -S kciss && \
    adduser -S -u "$UID" -g "$GID" kciss
COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=builder /go/src/github.com/fabricev/kciss/kciss /usr/local/bin/kciss

USER $UID
WORKDIR /home/kciss
ENTRYPOINT ["kciss"]