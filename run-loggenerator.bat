@echo off
echo Changelog Generator
echo ------------------
echo.
echo Enter the file path to the Git repository:
set /p REPO_PATH=

echo.
echo Running changelog generator...
echo.

"C:\Users\melbi\Documents\GitHub\changelog-gen\changelog-gen\bin\Release\net8.0\win-x64\publish\changelog-gen.exe" "%REPO_PATH%"

echo.
echo Press any key to exit...
pause > nul 