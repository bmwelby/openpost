# Disposable full-workspace install control for exact gallery feature candidate.
# Reproduces upstream CI install and Vitest server command; no provider credentials.
FROM oven/bun:1.4.4 AS frontend
WORKDIR /src
COPY . .
RUN bun install --frozen-lockfile
RUN cd apps/web && bun run sync && bunx vitest run --project server --maxWorkers=2
FROM alpine:3.24.1
COPY --from=frontend /src/apps/web/package.json /tmp/verified-source.json
RUN echo 'PASS: exact gallery feature full-workspace server test suite'
CMD ["sh","-c","echo 'QA done'; sleep 1"]
