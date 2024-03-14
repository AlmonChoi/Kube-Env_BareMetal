# FROM mhart/alpine-node:8
# ENV NODE_VERSION 8.9.4
# FROM ubuntu
FROM node:21-alpine

WORKDIR /opt/expressCart

COPY src/lib/ /opt/expressCart/lib/
COPY src/bin/ /opt/expressCart/bin/
COPY src/config/ /opt/expressCart/config/
COPY src/public/ /opt/expressCart/public/
COPY src/routes/ /opt/expressCart/routes/
COPY src/views/ /opt/expressCart/views/

COPY src/app.js /opt/expressCart/
COPY src/package.json /opt/expressCart/
COPY src/deploy.js /opt/expressCart/

RUN npm install

VOLUME /opt/expressCart/data

EXPOSE 1111
ENTRYPOINT ["npm", "start"]

