FROM node:24-alpine

WORKDIR /app

# 3. Copy dependency files first
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# 5. Create non-root user BEFORE copy source
RUN addgroup -S atm-blue-g \
 && adduser -S atm-blue -G atm-blue-g

# 6. Copy source code with correct ownership
COPY --chown=atm-blue:atm-blue-g . .

USER atm-blue

EXPOSE 3000

CMD ["node", "src/app.js"]
