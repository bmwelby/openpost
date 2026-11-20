# Disposable full-workspace install control for exact gallery feature candidate.
# Reproduces upstream CI install and Vitest server command; no provider credentials.
FROM node:24.19.0-bookworm-slim AS node24
FROM oven/bun:1.4.4 AS frontend
COPY --from=node24 /usr/local/bin/node /usr/local/bin/node
WORKDIR /src
COPY . .
ENV CI=true
RUN node --version && bun --version
RUN bun install --frozen-lockfile
RUN cd apps/web && bun run sync && bunx vitest run --project server
FROM alpine:3.24.1
COPY --from=frontend /src/apps/web/package.json /tmp/verified-source.json
RUN echo 'PASS: exact gallery feature full-workspace server test suite'
CMD ["sh","-c","echo 'QA done'; sleep 1"]
