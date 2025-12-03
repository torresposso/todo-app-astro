# Imagen base con Bun
FROM oven/bun:1 AS base
WORKDIR /app

# Copiamos solo los archivos de dependencias para aprovechar la cache
COPY package.json bun.lockb ./

# Instalación de dependencias de producción
FROM base AS prod-deps
RUN bun install --ci --production

# Instalación de dependencias completas para el build
FROM base AS build-deps
RUN bun install --ci

# Build de la aplicación
FROM build-deps AS build
COPY . .
RUN bun run build

# Runtime final
FROM oven/bun:1 AS runtime
WORKDIR /app

# Copiamos dependencias de producción
COPY --from=prod-deps /app/node_modules ./node_modules

# Copiamos el build
COPY --from=build /app/dist ./dist

ENV HOST=0.0.0.0
ENV PORT=4321

EXPOSE 4321

# Ejecutamos el server con Bun
CMD ["bun", "./dist/server/entry.mjs"]