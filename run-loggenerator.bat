@echo off
echo Changelog Generator
echo ------------------
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

echo.
echo Press any key to exit...
pause > nul 