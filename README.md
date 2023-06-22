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