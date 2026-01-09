FROM node:24-alpine

WORKDIR /app

COPY package.json package-lock*.json ./

RUN npm install

COPY . .

RUN addgroup -S atm-blue-g \
 && adduser -S atm-blue -G atm-blue-g \
 && chown -R atm-blue:atm-blue-g /app

USER atm-blue

EXPOSE 3000

CMD ["node", "src/app.js"]
