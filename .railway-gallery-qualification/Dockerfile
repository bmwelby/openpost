# QA ONLY: test the exact upstream gallery source with a genuinely built embedded frontend.
# This file is NOT part of the proposed upstream PR and has no provider credentials.
FROM node:24.19.0-bookworm-slim AS node24
FROM oven/bun:1.4.4 AS frontend
COPY --from=node24 /usr/local/bin/node /usr/local/bin/node
WORKDIR /src
COPY . .
ENV CI=true
RUN node --version && bun --version
RUN bun install --frozen-lockfile
RUN bun run --filter @openpost/web build
RUN bun run --filter @openpost/web package
RUN test -s apps/server/cmd/openpost/public/index.html

FROM public.ecr.aws/docker/library/golang:1.27.4-alpine AS full-backend
RUN apk add --no-cache gcc musl-dev sqlite-dev git ffmpeg
WORKDIR /src/apps/server
COPY apps/server/ ./
COPY --from=frontend /src/apps/server/cmd/openpost/public/ ./cmd/openpost/public/
COPY packages/platform-text/conformance/ /src/packages/platform-text/conformance/
COPY packages/plan-catalog/src/catalog.json /src/packages/plan-catalog/src/catalog.json
ENV GOMAXPROCS=2 GOMEMLIMIT=1500MiB GOGC=50 GOFLAGS="-p=1 -count=1 -timeout=30m"
RUN go mod download
RUN echo 'RUN: full untagged Go backend suite with authentic embedded frontend' && go test ./...

FROM alpine:3.24.1
COPY --from=full-backend /src/apps/server/go.mod /tmp/go-tested.mod
RUN echo 'PASS: untagged go test ./... with authentic embedded frontend'
CMD ["sh","-c","echo 'QA backend completed'; sleep 1"]
