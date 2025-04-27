# Post-commit hook to automatically generate changelog in PowerShell

# Get the repository root directory
$REPO_ROOT = git rev-parse --show-toplevel

# Path to the changelog generator
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$CHANGELOG_GEN_PATH = Join-Path -Path (Join-Path -Path (Split-Path -Parent $SCRIPT_DIR) -ChildPath "changelog-gen\bin\Release\net8.0\win-x64\publish") -ChildPath "changelog-gen.exe"

# Check if the commit message contains a specific string to indicate it's a changelog commit
$COMMIT_MSG = git log -1 --pretty=%B
if ($COMMIT_MSG -like "*[changelog skip]*" -or $COMMIT_MSG -like "*[skip changelog]*") {
    Write-Host "Skipping changelog generation due to commit message tag"
    exit 0
}

# Check last commit to see if only changelog files were modified
$CHANGED_FILES = @(git diff-tree --no-commit-id --name-only -r HEAD)
$CHANGELOG_FILES = @("changelog.md", "changelog.html", "./changelog.md", "./changelog.html")

# Convert all paths to their base names for comparison
$CHANGED_FILE_BASENAMES = @()
foreach ($file in $CHANGED_FILES) {
    $CHANGED_FILE_BASENAMES += (Split-Path -Leaf $file).ToLower()
}

# Check if all changed files are changelog files
$ALL_CHANGELOG_FILES = $true
foreach ($basename in $CHANGED_FILE_BASENAMES) {
    if ($CHANGELOG_FILES -notcontains $basename) {
        $ALL_CHANGELOG_FILES = $false
        break
    }
}

# If only changelog files were changed, skip generation
if ($ALL_CHANGELOG_FILES -and $CHANGED_FILE_BASENAMES.Count -gt 0) {
    Write-Host "Skipping changelog generation to prevent recursive commits (only changelog files were modified)"
    exit 0
}

# Run the changelog generator
if (Test-Path $CHANGELOG_GEN_PATH) {
    try {
        Write-Host "Generating changelog..."
        & "$CHANGELOG_GEN_PATH" "$REPO_ROOT"
        
        # Check if changelog was modified
        $STATUS = git status --porcelain
        if ($STATUS -match "changelog\.md|changelog\.html") {
            Write-Host "Changelog updated. Committing changes..."
            git add "$REPO_ROOT/changelog.md" "$REPO_ROOT/changelog.html" 2>$null
            git commit -m "Update changelog [changelog skip]" --no-verify
            Write-Host "Changelog committed successfully."
        } else {
            Write-Host "No changes to changelog detected."
        }
    } catch {
        Write-Host "Warning: Changelog generation failed, but commit was successful."
        Write-Host "Error: $_"
    }
} else {
    Write-Host "Warning: Changelog generator not found at $CHANGELOG_GEN_PATH"
}

# Always exit with success
exit 0 