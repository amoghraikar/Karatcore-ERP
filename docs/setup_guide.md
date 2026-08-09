# KaratCore ERP — Project Setup Guide

Comprehensive step-by-step developer guide for setting up and running **KaratCore ERP** across all supported platforms.

---

## 📋 System Requirements

| Tool | Required Version | Recommended |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.5.0` | `3.24.0` or higher |
| **Dart SDK** | `^3.5.0` | `3.5.0` or higher |
| **Xcode** (macOS/iOS) | `15.0+` | Latest stable |
| **Android Studio / SDK** | API level 21+ | API level 34 |
| **Visual Studio** (Windows) | C++ desktop workload | 2022 Build Tools |

---

## 🛠 Local Setup Instructions

### 1. Clone & Dependencies
```bash
git clone https://github.com/karatcore/karatcore_erp.git
cd karatcore_erp
flutter pub get
```

### 2. Verify Platform Enablement
Ensure target platforms are enabled on your machine:
```bash
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-web
```

---

## 🚀 Running the Application

### Desktop Targets
```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

### Web Target
```bash
flutter run -d chrome
```

### Mobile Targets
```bash
# iOS Simulator
flutter run -d iPhone

# Android Emulator
flutter run -d android
```

---

## 🧪 Testing & Analysis

```bash
# Run Static Code Analysis
flutter analyze

# Run All Unit & Widget Tests
flutter test
```
