#!/bin/bash

item_number=$1
docker_instance_id=${2:0:12}
openhands_container_name=openhands-app

# Function to check if container exists and is running
check_container() {
    if ! docker ps | grep -q $docker_instance_id; then
        echo "Error: Container $docker_instance_id is not running"
        exit 1
    fi
}

# Function to check if a directory is empty
is_dir_empty() {
    if [ -z "$(ls -A $1)" ]; then
        echo "Error: $1 is empty"
        return 1
    fi
    return 0
}

# Function to check if a file is empty
is_file_empty() {
    if [ ! -s "$1" ]; then
        echo "Error: $1 is empty"
        return 1
    fi
    return 0
}

# Check if container is running
check_container

# Create necessary directories
mkdir -p $item_number
mkdir -p $item_number/logs


# Create a timestamped directory for backup 
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
docker exec openhands-app mkdir -p /app/logs_backup/$docker_instance_id
docker exec openhands-app mkdir -p /app/logs_backup/$docker_instance_id/$timestamp

# Copy logs from the OpenHands container
echo "Copying logs from OpenHands container..."
# Find all files in the llm directory and its subdirectories
files=$(docker exec openhands-app find /app/logs/llm -type f)
for file in $files; do
    # Get just the filename without the path
    filename=$(basename "$file")
    # Copy the file to logs directory
    docker cp "openhands-app:$file" "./$item_number/logs/$filename"
    docker exec openhands-app mkdir -p /app/logs_backup
    # Copy the file to the timestamped directory instead of directly to logs_backup
    docker exec openhands-app mv "$file" /app/logs_backup/$docker_instance_id/$timestamp/
done

# Check if logs were copied successfully
if ! is_dir_empty "./$item_number"; then
    echo "Error: Failed to copy logs from container"
    exit 1
fi

# Get git diff from inside the container
echo "Creating git diff file..."
# Find the non-hidden folder in workspace
workspace_folder=$(docker exec $docker_instance_id find /workspace -maxdepth 1 -type d -not -path "/workspace" -not -path "/workspace/.*" | head -n 1)
if [ -z "$workspace_folder" ]; then
    echo "Error: No non-hidden folder found in workspace"
    exit 1
fi
echo "Found workspace folder: $workspace_folder"
docker exec $docker_instance_id bash -c "cd $workspace_folder && git diff main" > "./$item_number/git_diff.txt"

# Check if git diff was successful
if ! is_file_empty "./$item_number/git_diff.txt"; then
    echo "Error: Git diff is empty or failed"
    exit 1
fi

# Create zip archive
echo "Creating delivery archive..."
if ! zip -r "$item_number.zip" $item_number/; then
    echo "Error: Failed to create zip archive"
    exit 1
fi

echo "Delivery archive created: $item_number.zip" 