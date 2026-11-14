# Disposable Go-only capabilities qualification, kept off the upstream feature branch.
# Uses the exact upstream gallery commit and includes test sources via the QA-only .dockerignore.
FROM public.ecr.aws/docker/library/golang:1.27.3-alpine AS capabilities-test
RUN apk add --no-cache gcc musl-dev sqlite-dev git
WORKDIR /src/apps/server
COPY apps/server/ ./
ENV GOMAXPROCS=1 GOMEMLIMIT=1500MiB GOGC=50
RUN go mod download
RUN echo 'QA: focused Bluesky capabilities tests' && go test -p 1 -count=1 -v -timeout 10m -run 'TestBluesky' ./internal/capabilities
RUN echo 'QA: all capabilities package tests (quiet failures only)' && go test -p 1 -count=1 -timeout 15m ./internal/capabilities
RUN echo 'QA: targeted platform gallery tests' && go test -p 1 -count=1 -v -timeout 10m -run 'TestBlueskyGallery' ./internal/platform

FROM alpine:3.24.1 AS qualification-result
COPY --from=capabilities-test /src/apps/server/go.mod /tmp/qualified-go.mod
RUN echo 'PASS: isolated Go capabilities and gallery package qualification'
CMD ["sh", "-c", "echo 'QA completed'; sleep 1"]
