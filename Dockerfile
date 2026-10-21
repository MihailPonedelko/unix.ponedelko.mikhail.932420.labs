FROM node:24-bookworm-slim
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev
COPY controller.js worker.js ./
CMD ["node", "controller.js"]
