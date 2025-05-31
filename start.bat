@echo off

:: --- Configuration ---
set IMAGE_NAME=muscle
set IMAGE_TAG=latest
set CONTAINER_NAME=muscle-app
set HOST_PORT=8877
set CONTAINER_PORT=8877
set IMAGE_FILE=muscle.tar

:: --- Initial Checks ---
docker --version > nul 2>&1
if %errorlevel% neq 0 (
  echo [ERROR] Docker not found or not running.
  echo Please ensure Docker Desktop is installed and running.
  goto :eof
)

if not exist "input" (
  mkdir "input"
  echo Created 'input' directory
)

if not exist "output" (
  mkdir "output"
  echo Created 'output' directory
)

:: --- Load Docker image from file only if it doesn't exist ---
docker image inspect %IMAGE_NAME%:%IMAGE_TAG% > nul 2>&1
if %errorlevel% neq 0 (
  echo Image %IMAGE_NAME%:%IMAGE_TAG% not found in Docker.
  if exist "%IMAGE_FILE%" (
    echo Loading Docker image from %IMAGE_FILE%...
    docker load -i %IMAGE_FILE%
  ) else (
    echo [ERROR] Docker image file %IMAGE_FILE% not found.
    echo Cannot continue without the Docker image. Please ensure the file exists.
    goto :eof
  )
) else (
  echo Docker image %IMAGE_NAME%:%IMAGE_TAG% is already loaded.
)

:: --- Run Container ---
echo Starting container...
echo Access at http://localhost:%HOST_PORT%
echo Press Ctrl+C in this window to stop.

:: Start browser after a delay
powershell -WindowStyle Hidden -Command "Start-Sleep -Seconds 8; Start-Process http://localhost:%HOST_PORT%"

:: Run the container with console output
docker run -p %HOST_PORT%:%CONTAINER_PORT% -v "%cd%\input":/app/input:ro -v "%cd%\output":/app/output --name %CONTAINER_NAME% --rm %IMAGE_NAME%:%IMAGE_TAG% voila --no-browser --port=8877 --Voila.ip=0.0.0.0 --template=lab muscle.ipynb

echo Container exited with code %errorlevel%
pause