@echo off
echo Changelog Generator - Install Git Hooks
echo -------------------------------------
echo.

echo Enter the file path to the Git repository:
set /p REPO_PATH=

if not exist "%REPO_PATH%\.git" (
    echo Error: %REPO_PATH% is not a valid git repository.
    goto :end
)

echo.
echo Installing post-commit hook...

:: Create hooks directory if needed
if not exist "%REPO_PATH%\.git\hooks" mkdir "%REPO_PATH%\.git\hooks"

:: Copy the appropriate hook based on system
if exist "%~dp0post-commit.ps1" (
    :: Setup PowerShell hook runner
    (
        echo @echo off
        echo powershell.exe -ExecutionPolicy Bypass -File "%~dp0post-commit.ps1"
    ) > "%REPO_PATH%\.git\hooks\post-commit"
    echo PowerShell hook installed.
) else (
    copy "%~dp0post-commit.hook" "%REPO_PATH%\.git\hooks\post-commit"
    echo Shell hook installed.
)

:: Make the hook executable (useful if running in Git Bash or WSL)
if exist "%ProgramFiles%\Git\usr\bin\chmod.exe" (
    "%ProgramFiles%\Git\usr\bin\chmod.exe" +x "%REPO_PATH%\.git\hooks\post-commit"
)

echo.
echo Git hook installed successfully!
echo Now a changelog will be automatically generated after each commit.

:end
echo.
echo Press any key to exit...
pause > nul 