#!/bin/bash

# Step 1: Install gnupg and curl if not already installed
echo "Step 1: Installing gnupg and curl..."
sudo apt-get update
sudo apt-get install -y gnupg curl

# Step 2: Import the MongoDB public GPG key
echo "Step 2: Importing MongoDB public GPG key..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

# Step 3: Create a list file for MongoDB
echo "Step 3: Creating a list file for MongoDB..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list


# Step 4: Reload local package database
echo "Step 4: Reloading local package database..."
sudo apt-get update

# Step 5: Install the MongoDB packages
echo "Step 5: Installing MongoDB packages..."
sudo apt-get install -y mongodb-org

# Output installation status
mongo_installed=$(dpkg-query -W -f='${Status}' mongodb-org 2>/dev/null | grep -c "ok installed")
if [ $mongo_installed -eq 1 ]; then
    echo "MongoDB Community Edition has been successfully installed."
else
    echo "MongoDB Community Edition installation failed. Please check logs for errors."
    exit 1
fi

# Step 6: Start MongoDB service
echo "Step 6: Starting MongoDB service..."
sudo systemctl start mongod

# Handle errors related to mongod service not found
if ! systemctl status mongod &> /dev/null; then
    echo "Failed to start mongod.service. Running 'sudo systemctl daemon-reload'..."
    sudo systemctl daemon-reload
    echo "Retrying to start mongod.service..."
    sudo systemctl start mongod
fi

# Step 7: Verify MongoDB service status
echo "Step 7: Verifying MongoDB service status..."
sudo systemctl status mongod

# Step 8: Enable MongoDB to start on system boot
echo "Step 8: Enabling MongoDB to start on system boot..."
sudo systemctl enable mongod

echo ""
echo "Additional Information:"
echo "- MongoDB has been installed as a service and should start automatically."
echo "- You can manage MongoDB service using systemctl. (e.g., systemctl start mongod)"
echo "- For further configuration and usage, refer to MongoDB documentation."
