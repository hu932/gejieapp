@echo off
set REPO_URL=https://github.com/hu932/gejieapp.git

git --version >nul 2>&1
if errorlevel 1 goto missing_git

cd /d "%~dp0"

if not exist ".git" goto init_repo
goto update_repo

:init_repo
git init
git branch -M main
git remote add origin %REPO_URL%
goto commit_code

:update_repo
git remote set-url origin %REPO_URL%
goto commit_code

:commit_code
git add .
git commit -m "build: auto commit"
git push -u origin main
if errorlevel 1 goto push_failed
goto push_success

:missing_git
pause
exit /b 1

:push_failed
pause
exit /b 1

:push_success
start "" "https://github.com/hu932/gejieapp/actions"
pause
