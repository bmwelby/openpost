# Disposable, no-production-access, exact-feature-source qualification.
# This QA branch differs from the upstream proposal only by this Dockerfile.
FROM oven/bun:1.3.11 AS web-tests
WORKDIR /src
COPY . .
RUN bun install --frozen-lockfile --filter @openpost/web --filter openpost --filter "./packages/*"
RUN bun run --filter @openpost/web test
RUN bun scripts/tasks.mjs build frontend

FROM public.ecr.aws/docker/library/golang:1.26.9-alpine AS backend-tests
RUN apk add --no-cache gcc musl-dev sqlite-dev git
WORKDIR /src
COPY --from=web-tests /src/apps/server /src/apps/server
WORKDIR /src/apps/server
RUN go mod download
RUN go test -timeout 15m ./internal/platform ./internal/capabilities
RUN go test -timeout 25m ./...

FROM alpine:3.24.1 AS qualification-result
COPY --from=backend-tests /src/apps/server/go.mod /tmp/qualified-go.mod
RUN echo "PASS: isolated Bun frontend tests and full Go backend tests"
CMD ["sh", "-c", "echo 'PASS: isolated frontend and backend build qualification'; sleep 1"]
