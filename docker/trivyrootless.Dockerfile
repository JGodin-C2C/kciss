ARG TRIVY_VERSION=0.19.2
ARG ALPINE_VERSION=3.14.0

FROM ghcr.io/aquasecurity/trivy:$TRIVY_VERSION AS trivy

FROM alpine:$ALPINE_VERSION
ARG UID="2000"

RUN apk --no-cache add ca-certificates=20191127-r5 && \
    adduser -S -u $UID -G root trivy
COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy
USER $UID

WORKDIR /home/trivy
ENTRYPOINT ["trivy"]