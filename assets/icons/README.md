# App Icon Setup Guide

## Current Status

Placeholder icons have been created for the MoneyManager app.

## Icon Specifications

### App Logo (app_logo.png)

- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Design**: Money wallet icon in Material 3 style
- **Color**: Primary Green (#4CAF50)

### Adaptive Icon Foreground (app_logo_foreground.png)

- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Safe Zone**: 432x432 pixels centered
- **Design**: Same wallet icon, optimized for Android adaptive icons

## Generating Final Icons

To generate all required icon sizes for Android and iOS, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

This will create:

- Android mipmap icons (all densities)
- Android adaptive icons
- iOS app icons (all sizes)
- Web manifest icons
- Windows and macOS icons

## Custom Icon Design

To replace the placeholder icons with your custom design:

1. Create a 1024x1024 PNG image with your logo
2. Save it as `assets/icons/app_logo.png`
3. For adaptive icons, create `assets/icons/app_logo_foreground.png`
4. Run the icon generator command above

## Material 3 Design Guidelines

- Use simple, recognizable shapes
- Maintain high contrast
- Follow Material 3 color palette
- Ensure icon works at small sizes (48x48)
- Test on both light and dark backgrounds

## Icon Resources

- [Material Design Icons](https://material.io/design/iconography)
- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons](https://developer.android.com/develop/ui/views/launch/icon_design_adaptive)
