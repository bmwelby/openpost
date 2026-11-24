#!/usr/bin/env bash
set -euo pipefail
test "$(git rev-parse HEAD)" = "c91c2547579ff598e6a8dc4413e5b28f0aaf9f34"
test -z "$(git status --porcelain)"
echo "APPLICATION_SHA=$(git rev-parse HEAD)"
go version; node --version; bun --version; ffmpeg -version | head -n 1
failed=0
run() {
  printf '\nCOMMAND: '; printf '%q ' "$@"; printf '\n'
  if "$@"; then rc=0; else rc=$?; failed=1; fi
  echo "EXIT=$rc"
}
run bun run format:check -- backend
run bash -c 'cd apps/server && go build -tags dev ./...'
run bash -c 'cd apps/server && go vet -tags dev ./...'
run go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0
run bun run lint -- backend
run bun run lint -- cli
run bun run build -- cli
run bun run test -- cli
run bash -c 'cd apps/server && go test -tags dev -p 1 -count=1 -timeout 30m -json ./internal/platform ./internal/capabilities ./internal/services/publisher ./internal/services/mediastore ./internal/api/handlers > /tmp/target.json; rc=$?; jq -s "{pass:map(select(.Action==\"pass\" and .Test!=null))|length,fail:map(select(.Action==\"fail\" and .Test!=null))|length,skip:map(select(.Action==\"skip\" and .Test!=null))|length,failures:map(select(.Action==\"fail\"))}" /tmp/target.json; jq -r "select(.Action==\"output\")|.Output" /tmp/target.json | tail -100; exit "$rc"'
run bun run test -- backend
run bun install --frozen-lockfile
run bun run lint -- frontend
run bun run check -- frontend
run bun run --cwd apps/web test:server
run bun run build -- frontend
run bash -c 'cd apps/server && go run ./cmd/openpost-media-limits > /tmp/media-limits.mdx && cd ../.. && bunx oxfmt /tmp/media-limits.mdx && diff -u apps/docs/content/docs/guides/media-limits.mdx /tmp/media-limits.mdx'
echo "QUALIFICATION_EXIT=$failed"
exit "$failed"
