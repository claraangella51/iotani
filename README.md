# IoTani - IoT-Based Early Warning System for Plant Disease Risk

IoTani is a production-grade Flutter mobile application designed for urban farmers to monitor plant health conditions in real-time. It provides early warnings when environmental conditions (soil moisture and light intensity) indicate potential disease risk.

## 🌱 Features

- **Real-Time Monitoring**: Monitor soil moisture and light intensity from your IoT devices
- **9 Built-in Plant Profiles**: Pre-configured thresholds for popular urban farming plants
- **Smart Risk Assessment**: Automatic detection of risky conditions (High Risk, Warning, Safe)
- **Actuator Control**: Manual and automatic control of irrigation pumps and UV lamps
- **Alert System**: Firebase Cloud Messaging notifications for high-risk conditions
- **Activity History**: Complete log of sensor readings, actuator actions, and system events
- **User Authentication**: Secure login with Firebase Authentication
- **Multi-Platform**: Designed for Android, with cross-platform Flutter code ready for iOS, web, and desktop

## 🎯 Plant Profiles Supported

### Buah (Fruits)
- Tomat Cherry 🍅
- Cabai Rawit 🌶️
- Stroberi 🍓

### Sayur (Vegetables)
- Selada 🥬
- Pakcoy 🥗
- Bayam 🌿

### Hias (Ornamental)
- Lidah Mertua 🪴
- Monstera 🌴
- Aglonema 🍃

## 📱 App Navigation

The app uses a bottom navigation bar with 4 main tabs:

1. **Beranda (Dashboard)** - Overview of active plant, sensor metrics, and recommendations
2. **Monitoring** - Detailed sensor readings with historical data
3. **Kontrol (Control)** - Manual/automatic actuator control
4. **Riwayat (History)** - Activity log and alert history

Plus one drawer/settings screen:
- **Device Profile** - Device information, plant settings, and configuration

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.8+
- Dart SDK
- iOS 11.0+ or Android API 21+
- Firebase account (for backend)

### Installation

1. Clone/navigate to project:
```bash
cd /Users/claraangella/Flutter_Project/iotani_berhasil
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Download `google-services.json` from Firebase Console
   - Place in `android/app/`
   - For iOS, download `GoogleService-Info.plist` and add to Xcode project

4. Run the app:
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 🏗️ Architecture

The app follows a **clean architecture** pattern with **feature-first** folder structure:

```
lib/
├── core/               # Theme, routing, Firebase services
├── features/           # Feature modules (auth, dashboard, monitoring, etc.)
├── shared/             # Reusable widgets and utilities
├── main.dart
└── app.dart
```

**State Management**: Riverpod  
**Routing**: Go Router  
**Database**: Firebase Realtime Database  
**Authentication**: Firebase Auth  
**Notifications**: Firebase Cloud Messaging

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

## 🔑 Key Concepts

### Active Plant Selection
- Users select an active plant from the **Beranda** (Dashboard) screen
- The selection is stored as a global state using Riverpod
- All other screens automatically use and display the active plant information
- No plant switching is possible from other screens

### Risk Status Calculation
Default threshold defines "High Risk":
- Soil moisture **> 80%** AND Light intensity **< 300 lux**
- This indicates conditions favoring fungal growth

### Smart Recommendations
- App compares current sensor values against plant's ideal range
- Provides contextual advice without claiming disease certainty
- Uses wording like "indikasi risiko" (risk indication) and "potensi risiko" (potential risk)

## 🎨 Design Highlights

- **Agriculture-Themed Colors**: Soft greens, mints, and earth tones
- **Clean UI**: Spacious layout with rounded cards and soft shadows
- **Responsive Design**: Adapts to different screen sizes
- **Bahasa Indonesia**: All UI text in Indonesian for local audience
- **Accessibility**: Clear status indicators with colors + icons + text

## 🔐 Security Considerations

For production deployment, ensure:
- Proper Firebase security rules
- Backend validation of sensor data
- Device authentication/authorization
- Secure IoT device communication
- User data privacy compliance

## 📊 Demo Mode

The app currently runs in demo mode with sample data:
- Pre-populated sensor readings
- Mock device state
- Sample alerts and history

To switch to real Firebase data, uncomment the streaming code in provider files (see ARCHITECTURE.md).

## 🛠️ Development

### Project Structure Highlights
- **Modular Features**: Each feature is independently developable
- **Reusable Widgets**: Common UI components in `shared/widgets/`
- **Strong Typing**: Null-safe Dart throughout
- **Riverpod Providers**: Centralized, reactive state management

### Key Files
- `lib/main.dart` - App entry point
- `lib/app.dart` - Root app widget
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/router/app_router.dart` - Navigation setup
- `lib/core/firebase/firebase_service.dart` - Firebase backend

## 📝 Notes

- **Prototype Scale**: Designed for prototype-scale urban farming (1-10 plants per user initially)
- **Android First**: Primary focus on Android, but Flutter code is cross-platform ready
- **Extensible**: Framework supports adding more sensors, features, and actuators
- **Language Support**: Currently Indonesian, easily adaptable to other languages

## 🐛 Troubleshooting

**Firebase initialization error?**
- Ensure Firebase configuration files are in correct locations
- Check Firebase project credentials

**Build errors?**
```bash
flutter clean
flutter pub get --upgrade
flutter pub get
```

**Hot reload not working?**
- Use hot restart or full rebuild

## 📚 Further Reading

- See [ARCHITECTURE.md](ARCHITECTURE.md) for comprehensive technical documentation
- Flutter docs: https://flutter.dev
- Riverpod docs: https://riverpod.dev
- Firebase Flutter: https://firebase.flutter.dev

## 📄 License

This project is provided as a prototype implementation for IoT-based urban farming monitoring.

---

**Version**: 1.0.0  
**Last Updated**: March 30, 2026  
**Flutter**: 3.10.8+

Made with ❤️ for urban farming in Indonesia 🌱

# iotani
