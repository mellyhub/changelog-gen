# Post-commit hook to automatically generate changelog in PowerShell

# Get the repository root directory
$REPO_ROOT = git rev-parse --show-toplevel

# Path to the changelog generator
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$CHANGELOG_GEN_PATH = Join-Path -Path (Join-Path -Path (Split-Path -Parent $SCRIPT_DIR) -ChildPath "changelog-gen\bin\Release\net8.0\win-x64\publish") -ChildPath "changelog-gen.exe"

# Run the changelog generator
& "$CHANGELOG_GEN_PATH" "$REPO_ROOT"

Write-Host "Changelog updated automatically after commit." 