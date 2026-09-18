FROM registry.access.redhat.com/ubi10/go-toolset:10.2-1789630856@sha256:c468f485f6bdc8ba6b106d63d4019851eaf1912182f7e67ff1a185234d58ebf7 AS builder
ARG TARGETOS
ARG TARGETARCH

USER 1001

WORKDIR /workspace
COPY --chown=1001:0 . .

# Match Makefile: -tags=dfrunsecurity; use vendored modules for hermetic-friendly builds
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} \
    go build -mod=vendor -tags=dfrunsecurity -ldflags="-s -w" -o dockerfile-json .

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.8@sha256:2e8edce823a48e51858f1fad3ff4cbf6875ce8a3f86b9eecf298bc2050c8652a
COPY --from=builder /workspace/dockerfile-json /usr/local/bin/dockerfile-json

# Required for ecosystem-cert-preflight-checks
COPY LICENSE /licenses/LICENSE

USER 65532:65532

LABEL description="Parse and query Dockerfiles as JSON"
LABEL io.k8s.description="Parse and query Dockerfiles as JSON"
LABEL io.k8s.display-name="dockerfile-json"
LABEL io.openshift.tags="konflux, dockerfile, cli"
LABEL summary="dockerfile-json"
LABEL name="dockerfile-json"
LABEL com.redhat.component="dockerfile-json"

ENTRYPOINT ["/usr/local/bin/dockerfile-json"]
