# Baseline control. No production credentials, provider accounts, runtime deploys or DB.
FROM oven/bun:1.4.4 AS frontend-baseline
WORKDIR /src
COPY . .
RUN bun install --frozen-lockfile --filter @openpost/web --filter openpost --filter "./packages/*"
RUN cd apps/web && bun run sync && bunx vitest run --project server --maxWorkers=2
FROM alpine:3.24.1
COPY --from=frontend-baseline /src/apps/web/package.json /tmp/baseline-package.json
RUN echo 'PASS: unmodified upstream main frontend server suite'
CMD ["sh","-c","echo 'Baseline frontend QA image complete'; sleep 1"]
