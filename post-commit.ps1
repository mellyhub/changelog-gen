# Post-commit hook to automatically generate changelog in PowerShell

# Get the repository root directory
$REPO_ROOT = git rev-parse --show-toplevel

# Path to the changelog generator
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$CHANGELOG_GEN_PATH = Join-Path -Path (Join-Path -Path (Split-Path -Parent $SCRIPT_DIR) -ChildPath "changelog-gen\bin\Release\net8.0\win-x64\publish") -ChildPath "changelog-gen.exe"

# Run the changelog generator but don't block commit if it fails
if (Test-Path $CHANGELOG_GEN_PATH) {
    try {
        & "$CHANGELOG_GEN_PATH" "$REPO_ROOT"
        Write-Host "Changelog updated automatically after commit."
    } catch {
        Write-Host "Warning: Changelog generation failed, but commit was successful."
        Write-Host "Error: $_"
    }
} else {
    Write-Host "Warning: Changelog generator not found at $CHANGELOG_GEN_PATH"
    Write-Host "Commit was successful, but changelog was not updated."
}

# Always exit with success to not block the commit
exit 0 