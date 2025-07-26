FROM node:24.0.0-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS pruner

WORKDIR /app

COPY . .

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

RUN pnpm deploy --filter "hinterland-registry" --prod pruned

FROM base AS builder

WORKDIR /app

COPY --from=pruner /app/pruned .

RUN pnpm build

FROM base AS runner

WORKDIR /app

COPY --from=builder /app/ .

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]