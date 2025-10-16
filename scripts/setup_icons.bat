@echo off
echo MoneyManager Icon Generator
echo ============================
echo.

echo Checking for Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not found!
    echo Please install Python from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Installing Pillow library...
pip install pillow >nul 2>&1

echo.
echo Generating placeholder icons...
cd scripts
python generate_icons.py
cd ..

echo.
echo Running Flutter icon generator...
call flutter pub get
call flutter pub run flutter_launcher_icons:main

echo.
echo ============================
echo ✓ Icons generated successfully!
echo.
echo Your app now has a launcher icon.
echo Rebuild your app to see the changes.
echo.
pause
