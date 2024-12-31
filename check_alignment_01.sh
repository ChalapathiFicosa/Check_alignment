#!/bin/bash

set -e  # Exit immediately if any command exits with a non-zero status

# Arrays to store results
aligned=()
not_aligned=()
diff_detected=()

# Update all submodules (if needed)
echo "Updating submodules..."
#git submodule update --init --recursive
echo "Submodule update complete."

for submodule in $(git submodule foreach --quiet 'echo $sm_path'); do
  echo ""
  echo "Checking submodule: $submodule"
  cd $submodule || { echo "Error: Failed to navigate to $submodule"; exit 1; }

  # Fetch latest updates
  echo "Fetching updates for $submodule..."
  git fetch origin || { echo "Error: Failed to fetch updates for $submodule"; exit 1; }

  # Ensure we're on the develop branch
  echo "Switching to develop branch in $submodule..."
  git checkout develop || { echo "Error: Failed to checkout develop branch in $submodule"; exit 1; }

  echo "Pulling latest changes from develop in $submodule..."
  git pull origin develop || { echo "Error: Failed to pull develop branch in $submodule"; exit 1; }

  # Pull latest changes from master branch before fetching its hash
  echo "Fetching latest changes from master branch in $submodule..."
  git checkout master || { echo "Error: Failed to checkout master branch in $submodule"; exit 1; }
  git pull origin master || { echo "Error: Failed to pull master branch in $submodule"; exit 1; }

  # Get the latest commit hashes of master and develop branches
  echo "Getting commit hashes for $submodule..."
  master_hash=$(git rev-parse origin/master) || { echo "Error: Failed to get master hash for $submodule"; exit 1; }
  develop_hash=$(git rev-parse origin/develop) || { echo "Error: Failed to get develop hash for $submodule"; exit 1; }

  # Check if develop is included in master
  echo "Comparing master and develop for $submodule..."
  if git merge-base --is-ancestor $develop_hash $master_hash; then
    echo "Aligned: master includes all commits from develop in $submodule."
    aligned+=("$submodule")
  else
    echo "Not Aligned: master does not include all commits from develop in $submodule."
    not_aligned+=("$submodule")
  fi

  # Check for differences between master and develop branches
  echo "Checking for differences between master and develop in $submodule..."
  if git diff origin/master..origin/develop --quiet; then
    echo "No differences found between master and develop in $submodule."
  else
    echo "Differences found between master and develop in $submodule."
    diff_detected+=("$submodule")
  fi

  cd - > /dev/null  # Return to the main repo path quietly
done

# Display results
echo ""
echo "================ Alignment Check Results ================"
echo "Aligned components:"
printf "%s\n" "${aligned[@]}"

echo ""
echo "Not Aligned components:"
printf "%s\n" "${not_aligned[@]}"

echo ""
echo "Components with differences between master and develop:"
printf "%s\n" "${diff_detected[@]}"

echo ""
echo "Alignment check completed."
