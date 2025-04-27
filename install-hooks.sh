#!/bin/bash
echo "Changelog Generator - Install Git Hooks"
echo "-------------------------------------"
echo

# Get repository path
read -p "Enter the path to your Git repository: " REPO_PATH

# Validate git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: $REPO_PATH is not a valid git repository."
    exit 1
fi

echo
echo "Installing post-commit hook..."

# Create hooks directory if needed
mkdir -p "$REPO_PATH/.git/hooks"

# Copy the hook file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/post-commit.hook" "$REPO_PATH/.git/hooks/post-commit"

# Make it executable
chmod +x "$REPO_PATH/.git/hooks/post-commit"

echo
echo "Git hook installed successfully!"
echo "Now a changelog will be automatically generated after each commit." 