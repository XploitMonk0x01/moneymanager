@echo off
REM MoneyManager Material 3 Expressive Icon Setup

echo � MoneyManager Material 3 Expressive Icon Setup
echo =============================================

echo.
echo � Material 3 Icon Requirements:
echo 1. Main Icon: "app_logo.png" (1024x1024 PNG)
echo 2. Adaptive Foreground: "app_logo_foreground.png" (1024x1024 PNG, optional)
echo 3. Place both in: "assets\icons\"
echo 4. Run: flutter pub get
echo 5. Run: dart run flutter_launcher_icons
echo.

echo 🎯 Material 3 Design Principles:
echo    ✨ Expressive personality (warm, trustworthy)
echo    🌈 Dynamic color support (adapts to user theme)
echo    📐 Rounded corners (16dp minimum radius)
echo    ♿ High contrast (works in light/dark modes)
echo    🎨 Material You color palette
echo.

REM Check if main logo exists
if exist "assets\icons\app_logo.png" (
    echo ✅ Main logo found: assets\icons\app_logo.png
    if exist "assets\icons\app_logo_foreground.png" (
        echo ✅ Adaptive foreground found: assets\icons\app_logo_foreground.png
        echo 🚀 Full Material 3 adaptive icon ready!
    ) else (
        echo ⚠️  Adaptive foreground missing (optional but recommended)
        echo 💡 Create app_logo_foreground.png for best Material 3 experience
    )
    echo.
    echo 🚀 Run these commands to apply Material 3 icons:
    echo    flutter pub get
    echo    dart run flutter_launcher_icons
) else (
    echo ❌ Main logo not found: assets\icons\app_logo.png
    echo 📁 Please add your Material 3 expressive logo
)

echo.
echo 🎨 Material 3 Design Resources:
echo    - Material 3 Guidelines: https://m3.material.io/
echo    - Color Tool: https://m3.material.io/theme-builder
echo    - Figma Material 3 Kit: https://www.figma.com/community/file/1035203688168086460
echo    - Adaptive Icons Guide: https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive

pause