# Delivery script
Script for creating the archive for delivery containing logs and git diff.

## Usage

First take the docker_instance_id from the output of the `hostname` command in the terminal within vscode inside OpenHands:

![image](https://github.com/user-attachments/assets/4f925487-7027-4687-bd72-07acbe2101d0)

Then take the item number from the platform. This will be a number like `Item_00163`.

With these 2 parameters, run the script:

```bash
./delivery.sh <item_number> <docker_instance_id>
```

- `<item_number>`: The item number to create the archive for.
- `<docker_instance_id>`: The instance id of the docker container.

## Example

```bash
 ./delivery.sh Item_00163 7b3591ae522f71af
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
