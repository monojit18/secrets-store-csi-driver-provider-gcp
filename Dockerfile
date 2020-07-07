FROM golang:1.14 as build-env
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /tmp/secrets-store-csi-driver-provider-gcp
COPY . ./
RUN go get -t ./...
RUN make licensessave
RUN go install \
    -trimpath \
    -ldflags "-extldflags '-static'" \
    github.com/GoogleCloudPlatform/secrets-store-csi-driver-provider-gcp

FROM gcr.io/distroless/base
COPY --from=build-env /tmp/secrets-store-csi-driver-provider-gcp/licenses /licenses
COPY --from=build-env /go/bin/secrets-store-csi-driver-provider-gcp /bin/
ENTRYPOINT ["/bin/secrets-store-csi-driver-provider-gcp", "-daemonset"]
