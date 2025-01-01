# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Install dependencies and Docker CLI
RUN apt-get update && apt-get install -y \
    sudo \
    docker.io && \
    apt-get clean

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . /app

# Add the jenkins user and grant it access to the Docker group
RUN groupadd -g 999 docker && \
    useradd -m -u 1000 -g docker -s /bin/bash jenkins && \
    usermod -aG docker jenkins && \
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the jenkins user
USER jenkins

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=app.py

# Run the application
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
