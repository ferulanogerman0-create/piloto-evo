# Evolution API (develop) + parche de Baileys para la vinculación (PR #2727).
# Fijado al commit revisado; sacar cuando Evolution publique el arreglo.
FROM alpine/git:latest AS src
RUN git clone https://github.com/cloviscoli/evolution-api.git /src \
 && cd /src && git checkout dffeac4fe2bf67855deb4881a4a492588f2b70d7

FROM node:24-alpine AS builder
RUN apk update && apk add --no-cache git ffmpeg wget curl bash openssl dos2unix
WORKDIR /evolution
COPY --from=src /src/package.json /src/package-lock.json /src/tsconfig.json /src/tsup.config.ts ./
COPY --from=src /src/patches ./patches
RUN npm ci --silent
RUN npx patch-package
COPY --from=src /src/src ./src
COPY --from=src /src/public ./public
COPY --from=src /src/prisma ./prisma
COPY --from=src /src/manager ./manager
COPY --from=src /src/.env.example ./.env
COPY --from=src /src/runWithProvider.js ./
COPY --from=src /src/Docker ./Docker
RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*
RUN ./Docker/scripts/generate_database.sh
RUN NODE_OPTIONS="--max-old-space-size=2048" npm run build
RUN grep -q companion_reg_refresh node_modules/baileys/lib/Socket/socket.js

FROM node:24-alpine AS final
RUN apk update && apk add tzdata ffmpeg bash openssl
ENV TZ=America/Argentina/Buenos_Aires
ENV DOCKER_ENV=true
WORKDIR /evolution
COPY --from=builder /evolution/package.json ./package.json
COPY --from=builder /evolution/package-lock.json ./package-lock.json
COPY --from=builder /evolution/node_modules ./node_modules
COPY --from=builder /evolution/dist ./dist
COPY --from=builder /evolution/prisma ./prisma
COPY --from=builder /evolution/manager ./manager
COPY --from=builder /evolution/public ./public
COPY --from=builder /evolution/.env ./.env
COPY --from=builder /evolution/Docker ./Docker
COPY --from=builder /evolution/runWithProvider.js ./runWithProvider.js
COPY --from=builder /evolution/tsup.config.ts ./tsup.config.ts
EXPOSE 8080
ENTRYPOINT ["/bin/bash", "-c", ". ./Docker/scripts/deploy_database.sh && npm run start:prod" ]
