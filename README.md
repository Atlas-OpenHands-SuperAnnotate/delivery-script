# Delivery script
Script for creating the archive for delivery containing logs and git diff.

## Usage

First take the container id from the docker app, by copying the `ID` below the container name. Another way to get the container id is to run `docker ps` and copy the container id from the column `CONTAINER ID`. It has to be the `runtime` container. Example:

```bash
> docker ps
CONTAINER ID   IMAGE                                                     COMMAND                  CREATED             STATUS             PORTS                                                                                                    NAMES
45472c1cebf1   docker.all-hands.dev/all-hands-ai/openhands:0.37          "/app/entrypoint.sh …"   About an hour ago   Up About an hour   0.0.0.0:3000->3000/tcp                                                                                   openhands-app
7b3591ae522f   docker.all-hands.dev/all-hands-ai/runtime:0.37-nikolaik   "/openhands/micromam…"   17 hours ago        Up About an hour   0.0.0.0:36088->36088/tcp, 0.0.0.0:44373->44373/tcp, 0.0.0.0:52232->52232/tcp, 0.0.0.0:56034->56034/tcp   openhands-runtime-36bea49dbd3a44d5926818c9a2fa86a4
```

In this case the container id is `7b3591ae522f`.

Using the Docker app:

![image](https://github.com/user-attachments/assets/da7a1471-afc2-4c5e-b433-26b9672fbbce)


Then take the item number from the platform. This will be a number like `Item_00163`.

With these 2 parameters, run the script:

```bash
./delivery.sh <item_number> <docker_instance_id>
```

- `<item_number>`: The item number to create the archive for.
- `<docker_instance_id>`: The instance id of the docker container.

## Example

```bash
 ./delivery.sh Item_00163 7b3591ae522f71af0b5407e5b395e47dc7a831694c0e345a2b112417bc6a2da5
```

## Output

The output will be a zip file named `Item_00163.zip` in the current directory.

## Requirements

- Docker must be installed and running
- The specified Docker container must be running
- The logs folder must have content. For that, you need to prompt at least something in the app.
- You need to run the docker container with the `DEBUG` flag enabled. Otherwise the logs will not be available.

```bash
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.37-nikolaik

docker run -it --rm --pull=always \
    -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.37-nikolaik \
    -e LOG_ALL_EVENTS=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.openhands-state:/.openhands-state \
    -p 3000:3000 \
    --env DEBUG=1 \
    --add-host host.docker.internal:host-gateway \
    --name openhands-app \
    docker.all-hands.dev/all-hands-ai/openhands:0.37
```
