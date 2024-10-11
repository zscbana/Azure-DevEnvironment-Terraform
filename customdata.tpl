#!/bin/bash

# Update package index and install prerequisites
sudo apt-get update -y && sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable repository for Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index again
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the user to the Docker group
sudo usermod -aG docker ubuntu
