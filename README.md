# Getting Started With Docker
```
docker run -d -p 80:80 docker/getting-started
```
*   run the container in detached mode (in the background), mapping port 80 of the host to port 80 of the container, using docker/getting-started as the iamge
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
*   after building an image, you can push it to dockerhub
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