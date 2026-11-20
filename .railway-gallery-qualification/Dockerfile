# QA-only: confirm the generated media-limit guide is reproducible from the capability catalogue.
FROM public.ecr.aws/docker/library/golang:1.27.4-alpine AS generated
WORKDIR /src/apps/server
COPY apps/server/ ./
RUN go run ./cmd/openpost-media-limits > /tmp/regenerated.mdx

FROM oven/bun:1.4.4 AS verify-docs
COPY --from=generated /tmp/regenerated.mdx /tmp/regenerated.mdx
COPY apps/docs/content/docs/guides/media-limits.mdx /tmp/committed.mdx
RUN bunx oxfmt@0.61.0 --write /tmp/regenerated.mdx && (cmp /tmp/regenerated.mdx /tmp/committed.mdx || (echo "Generated media limits differ from committed content"; diff -u /tmp/committed.mdx /tmp/regenerated.mdx; exit 1))
RUN echo 'PASS: authored capability catalogue produces identical generated media-limits documentation'
CMD ["sh", "-c", "echo 'PASS generated docs'; sleep 1"]
