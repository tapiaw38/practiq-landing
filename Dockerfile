FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Astro/Vite only expose PUBLIC_-prefixed vars to client code, and only if
# they're present at build time — promoting the compose build arg to the
# environment here is what makes the plans fetch hit the right API in prod.
ARG PUBLIC_PRACTIQ_API_URL
ENV PUBLIC_PRACTIQ_API_URL=$PUBLIC_PRACTIQ_API_URL

RUN npm run build

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
