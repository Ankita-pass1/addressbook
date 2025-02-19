#!/bin/bash

# Define project directory and Git repository URL
PROJECT_DIR="addressbook"
GIT_REPO_URL="https://github.com/Ankita-pass1/addressbook.git"
BRANCH_NAME="b1"

# Update package list and upgrade existing packages
echo "Updating package list..."
sudo yum update -y

# Install Java (OpenJDK 11)
#echo "Installing Java..."
#sudo yum install java -y 

# Install Maven
#echo "Installing Maven..."
#sudo yum install -y maven

# Install Git
echo "Installing Git..."
sudo yum install -y git

# Verify installations
echo "Verifying installations..."
#java -version
#mvn -version
git --version

# Check if the project directory exists
if [ -d "$PROJECT_DIR" ]; then
    echo "Project directory exists. Pulling the latest changes from the repository..."
    cd "$PROJECT_DIR"
    git checkout "$BRANCH_NAME"  # Ensure we are on the correct branch
    git pull origin "$BRANCH_NAME"
else
    echo "Project directory does not exist. Cloning the repository..."
    git clone -b "$BRANCH_NAME" "$GIT_REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# Run Maven package
#echo "Running Maven package..."
#mvn  package
sudo docker build -t $1:$2 /home/ec2-user/addressbook
echo "Script completed successfully."
