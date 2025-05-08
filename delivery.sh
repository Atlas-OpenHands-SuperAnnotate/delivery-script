#!/bin/bash

# Function to check if container exists and is running
check_container() {
    if ! docker ps | grep -q openhands-app; then
        echo "Error: OpenHands container is not running"
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
mkdir -p logs

# Copy logs from the OpenHands container
echo "Copying logs from OpenHands container..."
# Find all files in the llm directory and its subdirectories
files=$(docker exec openhands-app find /app/logs/llm -type f)
for file in $files; do
    # Get just the filename without the path
    filename=$(basename "$file")
    # Copy the file to logs directory
    docker cp "openhands-app:$file" "./logs/$filename"
done

# Check if logs were copied successfully
if ! is_dir_empty "./logs"; then
    echo "Error: Failed to copy logs from container"
    exit 1
fi

# Get git diff from inside the container
echo "Creating git diff file..."
docker exec openhands-app git diff main > git_diff.txt

# Check if git diff was successful
if ! is_file_empty "git_diff.txt"; then
    echo "Error: Git diff is empty or failed"
    exit 1
fi

# Create zip archive
echo "Creating delivery archive..."
if ! zip -r delivery_archive.zip git_diff.txt logs/; then
    echo "Error: Failed to create zip archive"
    exit 1
fi

# Cleanup prompt
read -p "Do you want to clean up the logs folder? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleaning up logs folder..."
    docker exec openhands-app find /app/logs/llm -type f -delete
    docker exec openhands-app rm git_diff.txt
    echo "Cleanup complete!"
fi

echo "Delivery archive created: delivery_archive.zip" 