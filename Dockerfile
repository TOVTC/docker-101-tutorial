# start from an image of node built on Linux
FROM node:18-alpine
# set the working directory to an absolute path of /app (all commands will be executed relative to this directory)
WORKDIR /app
# copy the files from the current directory (where the Dockerfile is) to the working directory
# to support dependency caching, copy package.json first, install the dependencies, then copy the remainder of the files
COPY package.json yarn.lock ./
RUN yarn install --production
COPY . .
# use yarn to install dependencies using the command set in the CMD property
RUN yarn install --production
CMD ["node", "src/index.js"]