FROM node:24-alpine

# install bash
RUN apk add --no-cache bash

ENV NPM_CONFIG_UPDATE_NOTIFIER=false

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# 5. Create non-root user BEFORE copy source
RUN addgroup -S atm-blue-g \
 && adduser -S atm-blue -G atm-blue-g

# 6. Copy source code with correct ownership
COPY --chown=atm-blue:atm-blue-g . .

USER atm-blue

RUN chmod +x src/start.sh

EXPOSE 3000

CMD ["src/start.sh"]
