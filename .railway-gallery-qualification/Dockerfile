# Upstream CI-matched Node 24 / Bun 1.4.4 failure-isolation control.
# Only QA-only Dockerfile and .dockerignore differ from upstream main.
FROM node:24.19.0-bookworm-slim AS node24
FROM oven/bun:1.4.4 AS frontend
COPY --from=node24 /usr/local/bin/node /usr/local/bin/node
WORKDIR /src
COPY . .
ENV CI=true
RUN node --version && bun --version
RUN bun install --frozen-lockfile
RUN cd apps/web && bun run sync && bunx vitest run --project server src/lib/stores/auth.test.ts src/lib/workflows/curl.test.ts src/lib/video-editor/timeline/actions/keyframes.test.ts
FROM alpine:3.24.1
COPY --from=frontend /src/apps/web/package.json /tmp/node24-control.json
RUN echo 'PASS: Node 24 control tests for upstream frontend'
CMD ["sh","-c","echo 'QA done'; sleep 1"]
