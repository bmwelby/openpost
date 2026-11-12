# Disposable exact-feature regression qualification. No database, credentials or live provider.
# bun pinned to packageManager (openpost/package.json).
FROM oven/bun:1.4.4 AS web-tests
WORKDIR /src
COPY . .
RUN bun install --frozen-lockfile --filter @openpost/web --filter openpost --filter "./packages/*"
RUN cd apps/web && bun run sync && bunx vitest run --project server src/lib/media-capabilities.test.ts

FROM public.ecr.aws/docker/library/golang:1.27.3-alpine AS backend-tests
RUN apk add --no-cache gcc musl-dev sqlite-dev git
WORKDIR /src
COPY --from=web-tests /src/apps/server /src/apps/server
WORKDIR /src/apps/server
RUN go mod download
RUN go test -timeout 15m ./internal/platform ./internal/capabilities
RUN go test -timeout 25m ./...

FROM alpine:3.24.1 AS qualification-result
COPY --from=backend-tests /src/apps/server/go.mod /tmp/qualified-go.mod
RUN echo "PASS: focused Bun gallery tests, focused and full Go backend tests"
CMD ["sh", "-c", "echo 'PASS: isolated gallery build qualification'; sleep 1"]
