# Getting Started With Docker
*   run in Powershell, not Bash
```
docker run -d -p 80:80 docker/getting-started
```
*   run the container in detached mode (in the background), mapping port 80 of the host to port 80 of the container, using docker/getting-started as the image

## Building Updates
```
docker build -t getting-started .
```
*   build a new image (run the Dockerfile), tagged as "getting-started", using the Dockerfile found in the current directory (.)
```
docker run -dp 3000:3000 getting-started
```
*   again, run the getting-started container in the background, mapping port 3000 to port 3000
```
docker: Error response from daemon: driver failed programming external connectivity on endpoint laughing_burnell 
(bb242b2ca4d67eba76e79474fb36bb5125708ebdabd7f45c8eaf16caaabde9dd): Bind for 0.0.0.0:3000 failed: port is already allocated.
```
*   indicates that a container is already running on the specified port
```
docker ps
docker stop <container-id>
docker rm <container-id>
```
*   displays containers and then stops and removes the specified container
```
docker rm -f <container-id>
```
*   stops and removes a container in the same command

## Sharing Applications
*   after building an image, you can push it to DockerHub
    *   first, create a new repository
    *   login to Docker using Docker Desktop or the following command
```
docker login -u
```
    *   then, give the existing image a new name by tagging it
```
docker tag <app-name> <username>/<tag-name>
```
    *   then use the command in the Docker command section to push your project to the new repository (if no tagname is specified, Docker will default to "latest")
```
docker push <username>/<app-name>:tagname
```
*   using https://labs.play-with-docker.com/ will let you run a new instance of an image
    *   after clicking "add new instance" use the following command to run your pushed app
```
docker run -dp 3000:3000 <username>/<app-name>
```

## Data Persistence (Named Volumes)
*   a running container uses various layers froman image for its filesystem and has its own "scratch space" to create/update/remove files
```
docker run -d ubuntu bash -c "shuf -i 1-10000 -n 1 -o /data.txt && tail -f /dev/null"
```
*   the above command starts a bash shell and invokes two commands using the && operator, one that selects a random number and one that writes that number to /data.txt
*   to read the generated number, use Docker Desktop to open a terminal for the container (hamurger -> additional actions -> open in terminal)
```
cat /data.txt
```
*   or use the terminal to run the following command to read the file (try the lrative path if it generates an error that indicates the file does not exist)
```
docker exec <container-id> cat /data.txt
```
*   this command will run the ls / command inside a new container based on ubuntu (the -it flag sets "interactive mode" and allows you to see the output of ls and interact with it if necessary)
```
docker run -it ubuntu ls /
```
*   looking for the data.txt file in this new container will reveal that it does not exist (because it was written to the scratch space of the previous container)
*   each container starts from the image definition each time it starts - you can create, update, and delete files, but those changes are lost when the container is removed
*   volumes provide the ability to connect specific filesystem paths of the container back to the host machine
    *   if a directory in the container is mounted, changes in that directory are also seen on the host machine
    *   if the directory is mounted across container restarts, the same fiels would appear
*   there are two main types of volumes, one of which is "named volumes"
*   the example application uses SQLite as its database, which is good for small applications
    *   our database is only one file, so making the file persist on the host will make it available to the next container
    *   to do so, we create a volume and attach (mount) it to the directory the data is stored in
    *   as our container writes to the todo.db file, the changes will be persisted to the host in the volume
```
docker volume create todo-db
```
*   creates a volume
```
docker run -dp 3000:3000 -v <volume-name>:<directory-within-container> <image-name>
```
*   the -v flag specifies a volume mount and the name of the volume is mapped to the directory inside the container
```
docker volume inspect <volume-name>
```
*   provides additional information about the volume, including where data is being stored
    *   the Mountpoint is the actual location on the disk where the data is stored

## Data Persistence (Bind Mounts)
*   bind mounts allow for control over the exact mountpoint on the host and can be used to persist data but is often used to provide additional data into containers
*   bind mounts can be used to mount soruce code into the container to monitor whether the code changes, respond to change, and see immediate changes
*   to start a container to support a dev workflow:
    *   mount source doe into the container
    *   install all dependencies, including dev dependences
    *   start nodemon to watch filesystem changes (example app is JS and Node)
```
docker run -dp 3000:3000 `
    -w /app -v "$(pwd):/app" `
    node:18-alpine `
    sh -c "yarn install && yarn run dev"
```
*   -dp 3000:3000 - runs the app in detached mode mapping port 3000 to 3000
*   -w /app - sets the container's working directory where the command will run from
*   -v "$(pwd):/app" - bind mount (link) to the host's present getting-started/app directory to the container's /app directory
    *   Docker needs absolute paths so use pwd to find the absolute path of the working directory
*   node:18-alpine - specifies image to use (base image for our app from Docekrfile)
*   sh - c "yarn install && yarn run dev" - command to start a shell (alpine doesn't have bash) and running yarn install to install all dependencies and start running dev
    *   in package.json, the dev script starts nodemon
```
docker logs -f <container-id>
```
*   allows you to watch logs
*   now the app does not need to be rebuilt between edits and changes will be reflected upon reload
*   stop the container then run a new build
```
docker build -t <app-name>
```
*   bind mounts are very common for local development setups using the docker run command will pull and install all build tools and environments required for app development
```
docker run
```

## Multi-Container Apps
*   each container should be responsible for one thing only (e.g. API's and front end scale differently, allows for isolated version updates, etc.)
*   if two containers are on the same network, they can talk to each other - if they aren't, they can't
*   there are two ways to put a container on a network: assign it at start or connect an existing container (here, create the network and then attach the container at startup)
```
docker network create <network-name>
```
*   creates the network the network
```
docker run -d `
    --network <network-name> --network-alias mysql `
    -v <volume-name>:/var/lib/mysql `
    -e MYSQL_ROOT_PASSWORD=secret `
    -e MYSQL_DATABASE=todos `
    mysql:8.0
```
*   the volume is mounted to the /var/lib/mysql directory, which is where MySQL stores its data - Docker recognizes that we want to use a named volume, so it creates one automatically without the "docker volume create" command needing to be run
*   the --network-alias flag is useful for finding the IP address of the mysql server container in a later step
```
docker exec -it <mysql-container-id> mysql -p
```
*   will connect to the database to verify that it is up and running (opens MySQL shell) - use the password in the environment variables defined when the container was created
```
docker run -it --network <app-name> nicolaka/netshoot
```
*   nicolaka/netshoot is a container that ships with a lot of tools for troubleshooting and debugging network issues
```
dig mysql
```
*   the "dig" command is a DNS tool that looks up the IP address for the hostname mysql - it uses the --network-alias flag to find the address (i.e. the app only needs to connect to a host named "mysql" and it will connect to the database)
*   "exit" will exit the netshoot container
*   MySQL requires the following variables
    *   MYSQL_HOST - the hostname for the running MySQL server
    *   MYSQL_USER - the username to use for the connection
    *   MYSQL_PASSWORD - the password to use for the connection
    *   MYSQL_DB - the database to use once connected
*   specifying connection settings using environment variables is discouraged for applications in production but acceptable for development
```
docker run -dp 3000:3000 `
  -w /app -v "$(pwd):/app" `
  --network todo-app `
  -e MYSQL_HOST=mysql `
  -e MYSQL_USER=root `
  -e MYSQL_PASSWORD=secret `
  -e MYSQL_DB=<database-name> `
  node:18-alpine `
  sh -c "yarn install && yarn run dev"
```

## Docker Compose
*   docker compose defines and allows sharing of multi-container applications
*   a YAML file defines services and can spin up or tear down the entire application with one command - its biggest advantage is the ability to define an application stack in one file and allow for easy development environments
*   create a file called "docker-compose.yml" in the root directory
```
docker compose up -d
```
*   spins up the app (in detached mode) using the docker compose file
*   a volume and a network are created (the volume is defined in docker compose, but the network is created by default)
```
docker compose logs -f
```
*   displays the logs from each service
```
docker compose logs -f app
```
*   add an argument to follow and view logs of a specific service
*   when the app starts up, it waits for MySQL to be up and ready before trying to connect - Docker doesn't have built in support to wait for another container to be up, but Node based projects can use the wait-port dependency
*   after starting up the project, Docker desktop groups containers together under the project name (the directory the docker-compose.yml file is located in)
```
docker compose down
```
*   stops the application and removes the network
*   by default, named volumes in the compose file are not removed when running docker compose down - add the "--volumes" flag to remove them

## Image Building Best Practices
```
docker scan <app-name>
```
*   scans the application for security vulnerabilities
*   Docker Hub can also be configured to automatically scan all newly pushed images automatically
```
docker image history <app-name>
```
*   displays how an image is composed (shows commands that were used to create aech layer within an image) from most to least recent
```
docker image history --no-trunc <app-name>
```
*   adding the "--no-trunc" flag provides the full output
*   when a layer is changed, all downstream layers have to be recreated - each command in a Dockerfile becomes a new layer in the image
*   to avoid yarn having to re-install all dependencies, structure the Dockerfile so that it supports caching of dependencies
    *   in Node, dependencies are defined in package.json, so copy only package.json first, install all dependencies, then copy everything else in
    *   that way, yarn dependences are only recreated if tehre are changes to package.json
*   a .dockerignore file should also be added to the root directory so node modules are not copied over, overwriting the files created in the RUN command
*   multi-stage builds might be needed for your application (e.g. nginx is a multi-stage container for apps such as React)