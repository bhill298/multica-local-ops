FROM golang:1.26.9-bookworm AS compiler
ARG MULTICA_REV
RUN git init /src && cd /src && git fetch --depth 1 https://github.com/multica-ai/multica.git "$MULTICA_REV" && git checkout --detach FETCH_HEAD && test "$(git rev-parse HEAD)" = "$MULTICA_REV"
WORKDIR /src/server
# Match upstream's release metadata to the checked-out commit. ls-remote
# includes the peeled commit for annotated tags as well as lightweight tags.
RUN set -eu; \
    git ls-remote --tags https://github.com/multica-ai/multica.git 'refs/tags/v*' > /tmp/release-tags; \
    version=$(awk -v rev="$MULTICA_REV" '$1 == rev && $2 ~ /^refs\/tags\/v[0-9]+\.[0-9]+\.[0-9]+(\^\{\})?$/ { sub(/^refs\/tags\/v/, "", $2); sub(/\^\{\}$/, "", $2); print $2 }' /tmp/release-tags | sort -V | tail -1); \
    CGO_ENABLED=0 go build -trimpath \
      -ldflags "-X main.version=${version:-dev} -X main.commit=$(git rev-parse --short HEAD) -X main.buildCommit=$MULTICA_REV -X main.date=$(date -u +%FT%TZ)" \
      -o /multica ./cmd/multica
FROM node:24-bookworm-slim AS node
FROM multica-local/worker-tools:bookworm AS base
USER root
COPY --from=compiler /multica /usr/local/bin/multica
COPY --from=node /usr/local/ /usr/local/
FROM base AS codex
RUN npm install -g @openai/codex@0.171.0 && codex --version
USER worker
FROM base AS claude
RUN npm install -g @anthropic-ai/claude-code@2.1.329 && claude --version
USER worker
FROM base AS agy
RUN curl -fsSL https://antigravity.google/cli/install.sh -o /tmp/agy-install && bash /tmp/agy-install --dir /usr/local/bin && agy --version && rm /tmp/agy-install
USER worker
