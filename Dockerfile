FROM node:20-alpine AS build

RUN npm install -g pnpm

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN pnpm install

COPY . .

RUN pnpm run build --configuration=production

FROM node:20-alpine AS production

RUN npm install -g pnpm

WORKDIR /app

COPY --from=build /app/dist/angular-app/browser ./dist
COPY --from=build /app/package.json ./

RUN pnpm install --prod

EXPOSE 4201


CMD ["pnpm", "exec", "ng", "serve", "--host", "0.0.0.0", "--configuration=production"]
