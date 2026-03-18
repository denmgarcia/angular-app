FROM node:20-alpine AS build

RUN npm install -g pnpm && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup


WORKDIR /app

RUN chown -R appuser:appgroup /app

USER appuser

COPY --chown=appuser:appgroup package.json pnpm-lock.yaml* ./


RUN pnpm install


COPY --chown=appuser:appgroup . .

EXPOSE 4200

# Start command
CMD ["pnpm", "exec", "ng", "serve", "--host", "0.0.0.0", "--poll=2000"]
