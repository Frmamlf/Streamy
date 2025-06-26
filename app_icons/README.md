# Streamy App Icons & Assets

This directory contains all the professionally designed icons and promotional assets for the Streamy streaming app.

## 🎨 Design Concept

The Streamy app icon features:
- **Modern gradient background** with purple theme (#6200EA to #1A0047)
- **Central play button** symbolizing video streaming
- **Film strip elements** representing movie/TV content
- **Movie camera and video screen icons** for content variety
- **Google Material Design principles** for consistency

## 📁 Directory Structure

```
app_icons/
├── android/                          # Android app icons (all densities)
│   ├── mipmap-mdpi/ic_launcher.png   # 48x48px
│   ├── mipmap-hdpi/ic_launcher.png   # 72x72px
│   ├── mipmap-xhdpi/ic_launcher.png  # 96x96px
│   ├── mipmap-xxhdpi/ic_launcher.png # 144x144px
│   └── mipmap-xxxhdpi/ic_launcher.png# 192x192px
├── streamy_icon_1024.png             # High-res version (1024x1024)
└── streamy_icon_4k.png               # Ultra high-res 4K version (4096x4096)

promotional_assets/
├── feature_graphic_1024x500.png      # Google Play Store feature graphic
└── app_store_screenshot_bg.png       # App Store promotional background
```

## 🔧 Technical Specifications

### Android Icons
- **Format**: PNG with transparency
- **Color Profile**: sRGB
- **Densities**: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
- **Adaptive Icon**: Yes (API 26+)
- **Background**: Gradient vector drawable
- **Foreground**: Vector drawable with play button and film elements

### iOS Icons
- **Format**: PNG without transparency
- **Sizes**: Multiple sizes from 20x20 to 1024x1024
- **Location**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 4K Icon
- **Resolution**: 4096x4096 pixels
- **Use Case**: Marketing materials, website, high-DPI displays
- **File Size**: ~98KB optimized PNG

## 🎯 Usage Guidelines

### Colors
- **Primary**: #6200EA (Purple)
- **Secondary**: #3700B3 (Dark Purple)
- **Accent**: #1A0047 (Very Dark Purple)
- **Text/Icons**: #FFFFFF (White)

### Spacing
- **Safe Area**: 15% border radius for rounded corners
- **Icon Padding**: 20% internal padding for visual balance
- **Element Spacing**: Proportional to icon size

## 📱 Implementation

### Android
Icons are automatically integrated into the Flutter app:
```xml
<!-- Main launcher icon -->
<application android:icon="@mipmap/ic_launcher">

<!-- Adaptive icon (Android 8.0+) -->
<adaptive-icon>
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="ic_launcher_foreground"/>
</adaptive-icon>
```

### iOS
Icons are placed in the iOS asset catalog with all required sizes.

## 🚀 Marketing Assets

### Google Play Store
- **Feature Graphic**: 1024x500px for store listing
- **High-res Icon**: 512x512px (using our 1024px version)
- **Screenshots**: Custom backgrounds available

### Apple App Store
- **App Icon**: 1024x1024px for store listing
- **Screenshots**: Custom promotional backgrounds

## 🔄 Regeneration

To regenerate icons:
```bash
python generate_icons.py
python create_promotional_assets.py
```

## ✨ Features
- ✅ **4K Resolution** for future-proofing
- ✅ **Vector-based elements** for crisp scaling
- ✅ **Adaptive design** for Android
- ✅ **Material Design** compliance
- ✅ **iOS guidelines** compliance
- ✅ **Professional gradients** and shadows
- ✅ **Optimized file sizes**
- ✅ **Cross-platform compatibility**

---

*Created with Google Material Design icons and professional design principles for the Streamy video streaming application.*
