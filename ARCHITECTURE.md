# IoTani - App Architecture & Setup Guide

## Project Overview

**IoTani** is a production-style Flutter mobile application that serves as an IoT-based early warning system for plant disease risk in urban farming. The app monitors sensor data (soil moisture and light intensity) in real-time and provides alerts when conditions indicate potential disease risk.

## Architecture

IoTani follows a **clean architecture** pattern with **feature-first folder structure** and uses **Riverpod** for state management.

### Folder Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Main theme with agriculture colors
│   ├── router/
│   │   └── app_router.dart         # Go Router navigation setup
│   └── firebase/
│       └── firebase_service.dart   # Firebase integration layer
├── features/
│   ├── auth/
│   │   ├── domain/models/
│   │   ├── presentation/pages/    # LoginPage, RegisterPage
│   │   └── providers/             # Auth state providers
│   ├── dashboard/
│   │   ├── domain/models/         # PlantProfile, DeviceState
│   │   ├── presentation/
│   │   │   ├── pages/            # DashboardPage (Beranda)
│   │   │   └── widgets/          # Dashboard-specific widgets
│   │   └── providers/            # activePlantProvider, deviceStateProvider
│   ├── monitoring/
│   │   ├── domain/models/        # SensorReading
│   │   ├── presentation/pages/   # MonitoringPage
│   │   └── providers/            # Sensor data providers
│   ├── control/
│   │   ├── presentation/pages/   # ControlPage (Kontrol)
│   │   ├── presentation/widgets/ # Actuator controls
│   │   └── providers/            # Command state providers
│   ├── history/
│   │   ├── domain/models/        # AlertRecord, HistoryEntry
│   │   ├── presentation/pages/   # HistoryPage (Riwayat)
│   │   └── providers/            # History and alerts providers
│   └── settings/
│       └── presentation/pages/   # DeviceProfilePage
├── shared/
│   ├── widgets/                  # Reusable UI components
│   │   ├── bottom_nav_shell.dart
│   │   ├── status_badge.dart
│   │   ├── metric_card.dart
│   │   ├── actuator_button.dart
│   │   └── plant_selector_widget.dart
│   └── extensions/               # Dart extensions
├── main.dart                       # App entry point
└── app.dart                        # Root app widget
```

### Key Design Patterns

#### 1. **State Management with Riverpod**

- **Global Active Plant**: `activePlantProvider` - Only Beranda can update this
- **Device State**: `deviceStateProvider` - Streams real-time device data
- **Sensor Readings**: `sensorReadingsProvider` - Recent sensor history
- **Auth State**: `authStateProvider` - Firebase auth stream
- **Command Status**: `commandStatusProvider` - Tracks actuator commands

#### 2. **Feature-First Architecture**

Each feature is self-contained with:
- Domain layer (models, business logic)
- Presentation layer (pages, widgets)
- Providers (state management)

#### 3. **Firebase Integration**

- **FirebaseService** singleton class handles all Firebase operations
- Supports auth, realtime database, cloud messaging, commands
- Demo mode with sample data (can switch to real Firebase in production)

#### 4. **Navigation**

- **Go Router** for declarative routing
- Bottom navigation bar with 4 tabs (Beranda, Monitoring, Kontrol, Riwayat)
- Separate route for Device Profile settings
- Auth redirect logic

## Setup Instructions

### Prerequisites

- Flutter SDK 3.10.8 or higher
- Dart SDK compatible with Flutter
- iOS: Xcode with minimum deployment target iOS 11.0
- Android: targetSdkVersion 34+

### Step 1: Install Dependencies

```bash
cd /Users/claraangella/Flutter_Project/iotani_berhasil
flutter pub get
```

### Step 2: Configure Firebase (Required for Production)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. **For Android:**
   - Add Android app to Firebase project
   - Download `google-services.json`
   - Place in `android/app/`

3. **For iOS:**
   - Add iOS app to Firebase project
   - Download `GoogleService-Info.plist`
   - Add to Xcode project under `ios/Runner`

4. **Enable Firebase Services:**
   - Authentication (Email/Password)
   - Realtime Database
   - Cloud Messaging

### Step 3: Update Firebase Configuration

The Firebase initialization is handled in `lib/core/firebase/firebase_service.dart`. The `initializeFirebase()` function is called in `main.dart` before running the app.

### Step 4: Run the App

#### Android:
```bash
flutter run -d android
```

#### iOS:
```bash
flutter run -d ios
```

## Core Features & Implementation

### 1. Beranda (Dashboard)

**File**: `lib/features/dashboard/presentation/pages/dashboard_page.dart`

- Shows active plant with all plant profiles selector
- Displays real-time sensor metrics (soil moisture, light intensity)
- Shows risk status with smart recommendations
- Displays ideal ranges for currently selected plant
- Shows actuator status (pump, UV lamp)

**Key Provider**: `activePlantProvider` - Global state for active plant

### 2. Monitoring

**File**: `lib/features/monitoring/presentation/pages/monitoring_page.dart`

- Detailed view of current sensor readings
- Visual progress bars with ideal ranges
- Smart explanations based on sensor values
- Recent sensor history (last 5 readings)
- Plant-specific recommendations

**Key Provider**: `sensorReadingsProvider` - Streams sensor history

### 3. Kontrol (Control)

**File**: `lib/features/control/presentation/pages/control_page.dart`

- Mode selector: Automatic (disabled buttons) vs Manual (enabled buttons)
- Pump ON/OFF control with confirmation dialog
- UV Lamp ON/OFF control with confirmation dialog
- Command status feedback (loading, success, error)
- Manual mode only allows control in manual mode

**Key Providers**: `modeStateProvider`, `commandStatusProvider`

### 4. Riwayat (History)

**File**: `lib/features/history/presentation/pages/history_page.dart`

- Two tabs: Activity and Alerts
- Activity tab shows sensor readings, actuator actions, mode changes
- Alerts tab shows system warnings with risk status
- Timestamps and detailed descriptions
- Visual indicators for unread alerts

**Key Providers**: `historyProvider`, `alertsProvider`

### 5. Device Profile

**File**: `lib/features/settings/presentation/pages/device_profile_page.dart`

- Device information (ID, status, firmware)
- Active plant details
- Ideal range thresholds
- Logout button

## Risk Status Calculation

The app uses three risk statuses based on sensor conditions:

### Default Threshold (based on proposal):
- **Risiko Tinggi (High Risk)**: Soil moisture > 80% AND Light intensity < 300 lux
- **Waspada (Warning)**: Conditions approaching threshold or out of plant's ideal range
- **Aman (Safe)**: All conditions within plant's ideal range

### Status Colors:
- **Aman**: Green (#2D6A4F)
- **Waspada**: Amber (#F4A261)
- **Risiko Tinggi**: Red/Orange (#E76F51)

## Data Models

### PlantProfile
```dart
PlantProfile {
  id: String
  name: String
  category: String  // Buah, Sayur, Hias
  soilMoistureMin: int
  soilMoistureMax: int
  lightLuxMin: int
  lightLuxMax: int
}
```

### DeviceState
```dart
DeviceState {
  deviceId: String
  soilMoisture: int (0-100%)
  lightLux: int
  riskStatus: RiskStatus
  mode: Mode
  pumpStatus: bool
  uvLampStatus: bool
  lastUpdated: DateTime
  isConnected: bool
}
```

### SensorReading
```dart
SensorReading {
  id: String
  deviceId: String
  soilMoisture: int
  lightLux: int
  riskStatus: String
  timestamp: DateTime
}
```

## Built-in Plant Profiles

The app includes 9 pre-configured plant profiles:

**Buah (Fruits):**
- Tomat Cherry: 50-70% moisture, 3000-8000 lux
- Cabai Rawit: 50-80% moisture, 3000-9000 lux
- Stroberi: 60-80% moisture, 2000-6000 lux

**Sayur (Vegetables):**
- Selada: 60-80% moisture, 2000-5000 lux
- Pakcoy: 60-80% moisture, 2000-5000 lux
- Bayam: 60-80% moisture, 2500-6000 lux

**Hias (Ornamental):**
- Lidah Mertua: 20-40% moisture, 500-3000 lux
- Monstera: 40-60% moisture, 1000-3000 lux
- Aglonema: 40-60% moisture, 500-2500 lux

## Theme & Design

### Color Palette

- **Primary Green**: #2D6A4F (Deep forest)
- **Secondary Mint**: #52B788 (Mid-tone mint)
- **Accent Lime**: #95D5B2 (Light mint)
- **Neutral Warm**: #F5F3F0 (Cream)
- **Earth Brown**: #9B7E77 (Accent)

### Typography

Uses **Google Fonts: Poppins** for:
- Modern, friendly appearance
- Good readability on mobile
- Professional agricultural app aesthetic

## Demo Mode & Sample Data

The app currently runs in **demo mode** with simulated data:
- Device ID: "device_001"
- Sample sensor readings (moisture 65%, light 4500 lux)
- Demo alerts and history entries

To switch to real Firebase data, uncomment the Firebase streaming code in:
- `lib/features/dashboard/providers/device_state_provider.dart`
- `lib/features/monitoring/providers/sensor_readings_provider.dart`
- `lib/features/history/providers/history_provider.dart`

## Firebase Database Structure (Recommended)

```
users/{userId}
├── profile
├── activeDevice

devices/{deviceId}
├── state
│   ├── soilMoisture
│   ├── lightLux
│   ├── riskStatus
│   ├── mode
│   ├── pumpStatus
│   └── uvLampStatus

sensor_readings/{deviceId}/{timestamp}
├── soilMoisture
├── lightLux
├── riskStatus
├── createdAt

commands/{deviceId}/{commandId}
├── actionType
├── target
├── value
├── status
├── createdAt

alerts/{userId}/{alertId}
├── title
├── message
├── riskStatus
├── read
├── createdAt
```

## Key Implementation Notes

### Active Plant Consistency

- Only the **Beranda** (Dashboard) page can change the active plant
- All other screens automatically use and display the globally selected plant
- `activePlantProvider` is updated from Beranda
- Other screens read from `activePlantProvider` using `ref.watch()`

### Smart Recommendations

Based on sensor readings vs. plant ideal ranges:
- System generates contextual suggestions
- Uses plant-specific thresholds
- Avoids claiming certainty of disease
- Uses language like "indikasi risiko" (risk indication)

### Error Handling

- Loading states for async operations
- Graceful fallbacks when data unavailable
- User-friendly error messages in Bahasa Indonesia
- Offline mode support (demo data)

## Testing & Debugging

### Run Tests:
```bash
flutter test
```

### Run with Debug Output:
```bash
flutter run --verbose
```

### Check for Errors:
```bash
flutter analyze
```

## Future Enhancement Points

1. **Real IoT Device Integration**: Wire commands to actual hardware
2. **Advanced Analytics**: Historical trend analysis
3. **Push Notifications**: Implement FCM fully
4. **User Profiles**: Multi-device support
5. **Configurable Thresholds**: User-defined risk parameters
6. **Data Export**: CSV/PDF reports
7. **Offline Sync**: Local database with cloud sync
8. **Multi-language**: Indonesian, English, other languages

## Notes for Developers

- The app uses **strong null safety** throughout
- All widgets are documented with the intended use cases
- State management follows Riverpod best practices
- Navigation uses declarative Go Router patterns
- UI Components are highly reusable
- Clean separation between domain and presentation layers

## Troubleshooting

### Firebase Not Initializing
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is correctly placed
- Check Firebase project ID matches configuration

### Hot Reload Issues
- Run `flutter clean` then `flutter pub get`
- Restart the development server

### Build Errors
- Run `flutter clean`
- Run `flutter pub get --upgrade`
- Check Dart SDK and Flutter versions compatibility

## Contact & Support

This is a demonstration app for IoT-based urban farming monitoring. For production deployment, ensure proper Firebase security rules, backend validation, and IoT device integration.

---

**App Version**: 1.0.0  
**Created**: 2026-03-30  
**Flutter SDK**: 3.10.8+
