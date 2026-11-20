# Disposable qualification only: exact refreshed Bluesky gallery feature source.
# Does not access provider accounts, databases, media storage or production configuration.
FROM oven/bun:1.4.4 AS web-tests
WORKDIR /src
COPY . .
RUN bun install --frozen-lockfile --filter @openpost/web --filter openpost --filter "./packages/*"
RUN cd apps/web && bun run sync && bunx vitest run --project server src/lib/media-capabilities.test.ts
RUN cd apps/web && bun run lint:oxlint
RUN cd apps/web && bun run lint:svelte
RUN cd apps/web && bunx oxfmt --check src/lib/media-capabilities.ts src/lib/media-capabilities.test.ts

FROM public.ecr.aws/docker/library/golang:1.27.4-alpine AS backend-tests
RUN apk add --no-cache gcc musl-dev sqlite-dev git ffmpeg
WORKDIR /src/apps/server
COPY apps/server/ ./
COPY packages/platform-text/conformance/ /src/packages/platform-text/conformance/
COPY packages/plan-catalog/src/catalog.json /src/packages/plan-catalog/src/catalog.json
ENV GOMAXPROCS=2 GOMEMLIMIT=1500MiB GOGC=50
RUN go mod download
RUN go test -p 1 -count=1 -timeout 15m ./internal/platform ./internal/capabilities
RUN echo 'RUN: full Go backend tests (dev-tag, no generated embedded frontend needed)' && go test -tags dev -p 1 -count=1 -timeout 30m ./...

FROM alpine:3.24.1 AS qualification-result
COPY --from=backend-tests /src/apps/server/go.mod /tmp/qualified-go.mod
COPY --from=web-tests /src/apps/web/package.json /tmp/qualified-web-package.json
RUN echo 'PASS: frontend server tests and lint; Go targeted and full dev-tag backend tests'
CMD ["sh", "-c", "echo 'Disposable gallery test build complete'; sleep 1"]
