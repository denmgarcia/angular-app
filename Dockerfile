FROM node:20-alpine


# 1. Install pnpm as root first
RUN npm install -g pnpm \
    addgroup -S appgroup && adduser -S appuser -G appgroup \
    chown -R appuser:appgroup /app

WORKDIR /app

USER appuser

COPY --chown=appuser:appgroup package.json pnpm-lock.yaml* ./
RUN pnpm install

COPY --chown=appuser:appgroup . .

EXPOSE 4200

# This is a fallback; remember Compose overrides this!
CMD ["pnpm", "exec", "ng", "serve", "--host", "0.0.0.0", "--poll=2000"]
