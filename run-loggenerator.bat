@echo off
echo Changelog Generator
echo ------------------
echo.
echo 1. Generate changelog
echo 2. Install git hooks
echo.
echo Enter your choice (1 or 2):
set /p CHOICE=

if "%CHOICE%"=="1" (
    goto generate_changelog
) else if "%CHOICE%"=="2" (
    goto install_hooks
) else (
    echo Invalid choice
    goto end
)

:generate_changelog
echo.
echo Enter the file path to the Git repository:
set /p REPO_PATH=

echo.
echo Running changelog generator...
echo.

:: Use relative path instead of hardcoded absolute path
%~dp0changelog-gen\bin\Release\net8.0\win-x64\publish\changelog-gen.exe "%REPO_PATH%"

echo.
echo Would you like to generate static html from the changelog? (y/n)
set /p GENERATE_HTML=

if "%GENERATE_HTML%"=="y" (
    echo.
    echo Generating HTML version...
    %~dp0changelog-gen\bin\Release\net8.0\win-x64\publish\changelog-gen.exe "%REPO_PATH%" html
    echo HTML changelog generated successfully.
)
goto end

:install_hooks
echo.
call "%~dp0install-hooks.bat"
goto end

:end
echo.
echo Press any key to exit...
pause > nul 