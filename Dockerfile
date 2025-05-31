# Dockerfile

# Use a specific Python version for reproducibility
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# Install system dependencies (OpenCV might need some)
# Use apt-get for Debian/Ubuntu based images (like python:3.9-slim)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Docker caching
COPY requirements.txt .

# Install Python dependencies
# Use the CPU-specific index URL for PyTorch for reliability
RUN pip install --no-cache-dir -r requirements.txt \
    --extra-index-url https://download.pytorch.org/whl/cpu

# Copy the notebook into the container
COPY muscle.ipynb .

# Create directories for input/output within the container
# These paths are referenced in the Python script
RUN mkdir -p /app/input /app/output

# Expose the port Voila will run on
EXPOSE 8877

# Trust the notebook
RUN jupyter trust muscle.ipynb

# Define the command to run Voila
CMD ["voila", "--no-browser", "--port=8877", "--Voila.ip=0.0.0.0", "--template=lab", "muscle.ipynb"]
