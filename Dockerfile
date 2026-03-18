
FROM node:20-alpine AS build


RUN npm install -g pnpm


WORKDIR /app

COPY package.json pnpm-lock.yaml* ./
RUN pnpm install

COPY . .
RUN pnpm run build --configuration=production

FROM node:20-alpine AS production

RUN npm install -g http-server

WORKDIR /app

COPY --from=build /app/dist/angular-app/browser ./public

EXPOSE 4201

CMD ["http-server", "./public", "-p", "4201", "--proxy", "http://nginx:80?", "--spa"]
