#!/bin/bash

# --- Configuration ---
IMAGE_NAME="muscle"
IMAGE_TAG="latest"
CONTAINER_NAME="muscle-app"
HOST_PORT="8877"
CONTAINER_PORT="8877"
IMAGE_FILE="muscle.tar"

# --- Initial Checks ---
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker not found or not running."
    echo "Please ensure Docker Desktop is installed and running."
    exit 1
fi

if [ ! -d "input" ]; then
    mkdir "input"
    echo "Created 'input' directory"
fi

if [ ! -d "output" ]; then
    mkdir "output"
    echo "Created 'output' directory"
fi

# --- Load Docker image from file only if it doesn't exist ---
if ! docker image inspect "$IMAGE_NAME:$IMAGE_TAG" &> /dev/null; then
    echo "Image $IMAGE_NAME:$IMAGE_TAG not found in Docker."
    if [ -f "$IMAGE_FILE" ]; then
        echo "Loading Docker image from $IMAGE_FILE..."
        docker load -i "$IMAGE_FILE"
    else
        echo "[ERROR] Docker image file $IMAGE_FILE not found."
        echo "Cannot continue without the Docker image. Please ensure the file exists."
        exit 1
    fi
else
    echo "Docker image $IMAGE_NAME:$IMAGE_TAG is already loaded."
fi

# --- Run Container ---
echo "Starting container..."
echo "Access at http://localhost:$HOST_PORT"
echo "Press Ctrl+C in this window to stop."

# Start browser after a delay (works on macOS, Linux, and WSL)
(
    sleep 8
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "http://localhost:$HOST_PORT"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check if running in WSL
        if grep -qi microsoft /proc/version; then
            # WSL - use Windows browser
            cmd.exe /c start "http://localhost:$HOST_PORT" 2>/dev/null
        elif command -v xdg-open &> /dev/null; then
            # Native Linux
            xdg-open "http://localhost:$HOST_PORT"
        fi
    fi
) &

# Run the container with console output
docker run -p "$HOST_PORT:$CONTAINER_PORT" \
    -v "$(pwd)/input":/app/input:ro \
    -v "$(pwd)/output":/app/output \
    --name "$CONTAINER_NAME" \
    --rm \
    "$IMAGE_NAME:$IMAGE_TAG" \
    voila --no-browser --port=8877 --Voila.ip=0.0.0.0 --template=lab muscle.ipynb

EXIT_CODE=$?
echo "Container exited with code $EXIT_CODE"
read -p "Press Enter to continue..."