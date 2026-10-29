# Synapse — Adaptive Bento & Ambient Lock-Screen Second Brain

> **An ambient, widget-first second brain, medication regimen manager, and sedentary movement engine engineered for Android with zero cloud operating costs.**

---

## Highlights

- **🔒 Zero-Unlock Android Experience**: Hands-free *"Hey Buddy"* wake-word listening over the Android lock screen with ambient soundwave HUD and spoken TTS feedback.
- **📱 True Adaptive Bento Grid**: Obsidian aesthetic (`#050507`), fluid canvas wave animation, micro-bevel borders, and **zero inner-card scrollbars** (all cards size dynamically to content).
- **💸 $0 Operating Cost**: 100% on-device NLP intent extraction, local SQLite/SharedPreferences persistence, and offline wake-word detection. Zero paid third-party API dependencies.
- **📋 Clinical 30-Day Adherence Reporting**: Exportable clinician-ready reports tracking dose compliance, consecutive streaks, and biometrics.
- **🚀 Automated CI/CD**: Pre-configured GitHub Actions workflow compiling release APKs on every push.

---

## Architecture Overview

```
synapse/
├── .github/workflows/
│   └── build_apk.yml             # GitHub Actions CI workflow (Builds Android APK)
├── android/
│   ├── app/src/main/
│   │   ├── AndroidManifest.xml   # FOREGROUND_SERVICE_MICROPHONE & showWhenLocked
│   │   ├── kotlin/com/synapse/ambient/
│   │   │   ├── MainActivity.kt   # Lock-screen wake lock & battery exemption channel
│   │   │   └── SynapseGlanceWidget.kt # Glance home/lock screen widget provider
│   │   └── res/                  # AppWidget layouts & metadata
│   └── build.gradle              # Android Gradle configuration
├── lib/
│   ├── core/                     # Constants, dark luxury palette, haptics, theme
│   ├── models/                   # Regimen, hydration, movement, memory vault models
│   ├── providers/                # Riverpod state management
│   ├── services/                 # Offline NLP, TTS, storage, foreground voice
│   ├── ui/
│   │   ├── screens/              # Home bento, query sheet, lock screen simulator
│   │   └── widgets/              # Bento card, fluid wave, adherence ring, mic capsule
│   └── main.dart                 # Application entry point
├── preview/
│   └── index.html                # Interactive zero-install web simulator (port 8085)
└── test/                         # Comprehensive unit test suites
```

---

## Getting Started

### 1. Automated APK Build via GitHub Actions
Whenever code is pushed to this repository:
1. Head to the **Actions** tab on GitHub.
2. Select the latest **Build Synapse Android APK** run.
3. Download the compiled `synapse-release-apk` artifact directly to your Android device and install!

### 2. Local Development & Run
```bash
# Clone the repository
git clone https://github.com/amitksingh0880/synapse.git
cd synapse

# Install Flutter dependencies
flutter pub get

# Run unit test suites
flutter test

# Run on connected Android device or emulator
flutter run -d <your-android-device>
```

### 3. Interactive Web Simulator
To preview the adaptive bento UI and test lock-screen voice commands locally in your browser:
```bash
python -m http.server 8085 --directory preview
# Navigate to http://localhost:8085
```

---

## License

MIT License. Designed with privacy-first on-device telemetry.
