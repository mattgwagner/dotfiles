FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
EXPOSE 3000
CMD ["sh","-c","npm run stein:start && sleep 5 && tail -f ./node_modules/stein-core/*.log"]