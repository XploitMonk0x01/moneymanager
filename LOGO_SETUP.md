# 🎨 MoneyManager App Logo Setup

## Overview

This guide helps you set up a custom app logo for your MoneyManager Flutter application.

## Quick Setup

### Step 1: Create Your Logo

Create a **1024x1024 pixel PNG image** with your desired logo design.

**Design Recommendations:**

- 🏦 **Financial Theme**: Wallet, bank, money, charts
- 🎨 **Material 3 Style**: Modern, clean, minimalist
- 🟢 **Professional Colors**: Green, blue, teal (trust colors)
- ✨ **Scalable Design**: Looks good at all sizes

### Step 2: Place the Logo

Save your logo as `app_logo.png` in:

```
assets/icons/app_logo.png
```

### Step 3: Generate Icons

Run these commands:

```bash
# Install dependencies
flutter pub get

# Generate app icons for all platforms
dart run flutter_launcher_icons
```

### Step 4: Build & Test

```bash
# Build to see the new icon
flutter build apk --release
# or
flutter run
```

## Logo Design Tools

### Free Options:

- **Canva**: Easy drag-and-drop design
- **GIMP**: Full-featured image editor
- **Material Design Icons**: Google's icon library
- **Figma**: Professional design tool (free tier)

### Paid Options:

- **Adobe Illustrator**: Professional vector graphics
- **Sketch**: Mac-based design tool
- **Affinity Designer**: One-time purchase alternative

## Logo Specifications

| Platform | Size      | Format | Notes                         |
| -------- | --------- | ------ | ----------------------------- |
| Android  | 1024x1024 | PNG    | Auto-generated multiple sizes |
| iOS      | 1024x1024 | PNG    | Auto-generated for App Store  |
| Web      | 1024x1024 | PNG    | For web app manifest          |
| Windows  | 1024x1024 | PNG    | Desktop app icon              |

## Design Tips

### ✅ Do:

- Keep it simple and recognizable
- Use consistent brand colors
- Test at different sizes (16px to 1024px)
- Use transparent backgrounds
- Make it unique to your app

### ❌ Don't:

- Use text that's too small to read
- Create overly complex designs
- Use copyrighted images
- Ignore platform guidelines
- Make it too similar to existing apps

## Troubleshooting

### Icon not updating?

1. Delete old APK/app
2. Clean project: `flutter clean`
3. Regenerate icons: `dart run flutter_launcher_icons`
4. Rebuild: `flutter run`

### Size issues?

- Ensure logo is exactly 1024x1024 pixels
- Use PNG format with transparency
- Check file isn't corrupted

### Platform-specific issues?

- Android: Check `android:icon` in AndroidManifest.xml
- iOS: Verify Info.plist configuration
- Web: Check web/manifest.json

## Current Configuration

The app is configured to use:

- **Icon name**: `launcher_icon` (Android)
- **Source file**: `assets/icons/app_logo.png`
- **App name**: "MoneyManager"
- **Theme colors**: Green (#2E7D32, #1B5E20)

## Need Help?

1. Check the Flutter documentation: [flutter.dev/docs](https://flutter.dev/docs)
2. Review flutter_launcher_icons: [pub.dev/packages/flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
3. Open an issue in this repository

---

🎨 **Happy designing!** Your MoneyManager app deserves a beautiful icon!
