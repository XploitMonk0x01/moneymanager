#!/bin/bash
# MoneyManager Material 3 Expressive Icon Setup

echo "� MoneyManager Material 3 Expressive Icon Setup"
echo "=============================================="

# Check if ImageMagick is available for logo generation
if command -v convert &> /dev/null; then
    echo "✅ ImageMagick found. Generating Material 3 placeholder icons..."
    
    # Generate Material 3 style main logo (1024x1024)
    convert -size 1024x1024 xc:"#4CAF50" \
        -gravity center \
        \( -size 800x800 xc:"#2E7D32" \
           -geometry 800x800+0+0 \
           -alpha set -channel A -evaluate set 90% \) \
        -composite \
        \( -pointsize 300 -fill white -font DejaVu-Sans-Bold \
           -annotate 0 "💰" -geometry +0-80 \) \
        \( -pointsize 120 -fill white -font DejaVu-Sans-Bold \
           -annotate 0 "MM" -geometry +0+120 \) \
        assets/icons/app_logo.png
    
    # Generate adaptive foreground (1024x1024)
    convert -size 1024x1024 xc:none \
        -gravity center \
        -pointsize 300 \
        -fill "#2E7D32" \
        -font DejaVu-Sans-Bold \
        -annotate 0 "💰" \
        assets/icons/app_logo_foreground.png
    
    echo "✅ Material 3 placeholder icons generated!"
    echo "   - Main: assets/icons/app_logo.png"
    echo "   - Adaptive: assets/icons/app_logo_foreground.png"
else
    echo "❌ ImageMagick not found."
    echo "📝 Please create Material 3 expressive icons manually:"
    echo "   - Main icon: assets/icons/app_logo.png (1024x1024)"
    echo "   - Adaptive foreground: assets/icons/app_logo_foreground.png (1024x1024, optional)"
fi

echo ""
echo "🎯 Material 3 Design Principles:"
echo "   ✨ Expressive personality (warm, trustworthy)"
echo "   🌈 Dynamic color support"
echo "   📐 Rounded corners (16dp minimum)"
echo "   ♿ Accessible contrast"
echo "   🎨 Material You integration"
echo ""
echo "📱 After creating your Material 3 icons, run:"
echo "   flutter pub get"
echo "   dart run flutter_launcher_icons"
echo ""
echo "🎨 Material 3 Resources:"
echo "   - Guidelines: https://m3.material.io/"
echo "   - Theme Builder: https://m3.material.io/theme-builder"
echo "   - Figma Kit: https://www.figma.com/community/file/1035203688168086460"