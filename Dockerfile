FROM node:20-alpine

WORKDIR /app

COPY package*.json yarn.lock* ./

RUN corepack enable && yarn install --immutable --production && yarn cache clean

COPY . .

RUN addgroup -S atm-blue-g \
 && adduser -S atm-blue -G atm-blue-g \
 && chown -R atm-blue:atm-blue-g /app

USER atm-blue

EXPOSE 3000

CMD ["node", "src/app.js"]
