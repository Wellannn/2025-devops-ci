FROM node:20-alpine AS builder

RUN npm install -g pnpm@8

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build


FROM node:20-alpine AS production

RUN npm install -g pnpm@8

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
RUN chown -R appuser:appgroup /app
USER appuser

ENV NODE_ENV production
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --production --frozen-lockfile --prefer-offline

COPY --from=builder /app/dist ./dist
COPY public ./public

EXPOSE 3000

CMD ["pnpm", "start"]