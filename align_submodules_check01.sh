#!/bin/bash

# Submodule alignment check script

# Function to check for errors and exit if any command fails
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error during: $1"
        exit 1
    fi
}

# Log message for tracking progress
log() {
    echo "[INFO] $1"
}


#log "Navigating to submodule path."
#cd system_ecu_autosar/system_ecu_sysbios || { echo "Failed to navigate to system_ecu_autosar/system_ecu_sysbios"; exit 1; }

# Checkout the master branch in the main repo
echo "Running: git checkout master"
git checkout master
check_error "git checkout master"

# Update submodules to reflect the latest changes
echo "Running: git submodule update"
git submodule update
check_error "git submodule update"

# Show the current branch in the main repository
echo "Running: git branch"
git branch
check_error "git branch"

# Pull the latest changes from the main repository
echo "Running: git pull"
git pull
check_error "git pull"

# Update submodules again to reflect the latest changes
echo "Running: git submodule update"
git submodule update
check_error "git submodule update"

# Check the current branch of each submodule
log "Checking the current branch of each submodule."
echo "Running: git submodule foreach git branch"
git submodule foreach git branch
check_error "git submodule foreach git branch"

# Checkout the master branch of each submodule
log "Checking out master branch for each submodule."
echo "Running: git submodule foreach git checkout master"
git submodule foreach git checkout master
check_error "git submodule foreach git checkout master"

# Pull the latest changes in each submodule
log "Pulling latest changes in each submodule."
echo "Running: git submodule foreach git pull"
git submodule foreach git pull
check_error "git submodule foreach git pull"

# Show the status of the main repository and submodules
echo "Running: git status"
git status
check_error "git status"

echo "Running: git checkout develop"
git checkout develop
check_error "checkout develop"

# After completing submodule checks, remind to switch to develop branch manually
log "Submodule alignment check complete. Please proceed with manually checking out the develop branch."
