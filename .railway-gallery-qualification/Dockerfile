# QA ONLY: OpenPost upstream's actual frontend Chromium + production-mode Vitest commands.
# Microsoft Playwright image supplies Chromium/system libraries; Node/Bun versions match CI.
FROM oven/bun:1.4.4 AS bun_binary
FROM node:24.19.0-bookworm-slim AS node24
FROM mcr.microsoft.com/playwright:v1.61.1-noble AS frontend-browser
COPY --from=node24 /usr/local/bin/node /usr/local/bin/node
COPY --from=bun_binary /usr/local/bin/bun /usr/local/bin/bun
WORKDIR /src
COPY . .
ENV CI=true
RUN node --version && bun --version
RUN bun install --frozen-lockfile
RUN cd apps/web && bun run sync
RUN echo 'RUN: exact frontend production-mode Vitest suite' && bun run --filter @openpost/web test:production
RUN echo 'RUN: full frontend Chromium component suite across all 4 shards' && bun run --filter @openpost/web test:browser

FROM ubuntu:24.04
COPY --from=frontend-browser /src/apps/web/package.json /tmp/gallery-browser-tested.json
RUN echo 'PASS: full frontend production mode and Chromium browser component suite'
CMD ["sh","-c","echo 'QA browser completed'; sleep 1"]
