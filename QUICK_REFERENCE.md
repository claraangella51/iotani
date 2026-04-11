# IoTani Development Quick Reference

## 🚀 Getting Started

```bash
# Navigate to project
cd /Users/claraangella/Flutter_Project/iotani_berhasil

# Install dependencies
flutter pub get

# Run on Android device/emulator
flutter run -d android

# Run on iOS device/simulator
flutter run -d ios
```

## 📱 App Structure at a Glance

```
Beranda (Dashboard) ← Only place to change active plant
├── Show active plant
├── Plant selector (9 options)
├── Sensor metrics
├── Risk status
└── Recommendations

Monitoring
├── Detailed sensor readings
├── Progress bars for ranges
└── Smart explanations

Kontrol (Control)
├── Mode: Automatic ↔ Manual
├── Pump control (manual only)
├── UV lamp control (manual only)
└── Confirmation dialogs

Riwayat (History)
├── Activity tab
│   ├── Sensor readings
│   ├── Actuator actions
│   └── Mode changes
└── Alerts tab
    ├── System warnings
    └── Risk alerts

Device Profile (Settings)
├── Device info
├── Plant details
├── Threshold reference
└── Logout
```

## 🔑 Key Concepts Quick Tips

### Active Plant Provider
```dart
// Read active plant
final plant = ref.watch(activePlantProvider);

// Update active plant (only in Beranda!)
ref.read(activePlantProvider.notifier).state = newPlant;
```

### Device State
```dart
// Get device state stream
final deviceState = ref.watch(deviceStateProvider);

// Use in UI
deviceState.when(
  data: (state) => Text('Soil: ${state.soilMoisture}%'),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
);
```

### Sensor Readings
```dart
// Get recent readings
final readings = ref.watch(sensorReadingsProvider);

// Latest reading
final latest = ref.watch(latestSensorReadingProvider);
```

### Plant Info Access
```dart
// Get all plants
final plants = ref.watch(plantListProvider);

// Get specific plant
final plant = PlantProfile.getById('tomat_cherry');
```

## 🎨 Theme Colors & Usage

```dart
// Primary & Secondary
AppTheme.primaryGreen       // #2D6A4F - Main brand
AppTheme.secondaryMint      // #52B788 - Secondary
AppTheme.accentLime         // #95D5B2 - Accents

// Status Colors
AppTheme.statusAman         // Green - Safe
AppTheme.statusWaspada      // Amber - Warning
AppTheme.statusRisikoTinggi // Red - High Risk

// Text Colors
AppTheme.textDark           // #1B1B1B - Headings
AppTheme.textMedium         // #555555 - Body
AppTheme.textLight          // #999999 - Captions

// UI Elements
AppTheme.backgroundColor    // Background
AppTheme.cardColor          // Card backgrounds
AppTheme.dividerColor       // Borders/dividers
AppTheme.errorColor         // Errors
```

## 🛠️ Common Tasks

### Add New Plant Profile
```dart
// Edit: lib/features/dashboard/domain/models/plant_profile.dart
PlantProfile(
  id: 'new_plant_id',
  name: 'Plant Name',
  category: 'Buah',  // or 'Sayur' or 'Hias'
  soilMoistureMin: 50,
  soilMoistureMax: 70,
  lightLuxMin: 3000,
  lightLuxMax: 8000,
);
```

### Create New Feature Screen
```
1. Create directory: lib/features/myfeature/
2. Add subdirectories:
   - presentation/pages/
   - presentation/widgets/ (optional)
   - domain/models/ (if needed)
   - providers/
3. Create screen and providers
4. Add route in lib/core/router/app_router.dart
```

### Add Firebase Streaming
```dart
// In provider file, uncomment streaming code:
yield* service.streamDeviceState(deviceId).map((data) {
  // Transform Firebase data to model
  return DeviceState.fromJson(data);
});
```

### Handle Loading States
```dart
asyncData.when(
  data: (value) => Text(value),           // Data available
  loading: () => CircularProgressIndicator(),  // Loading
  error: (error, st) => Text('Error: $error'),  // Error
);
```

## 📊 Risk Status Logic

```dart
// Default threshold
if (soilMoisture > 80 && lightLux < 300) {
  return RiskStatus.risikoTinggi;  // High Risk
}

// Check plant-specific ranges
if (soilMoisture < plant.soilMoistureMin ||
    soilMoisture > plant.soilMoistureMax ||
    lightLux < plant.lightLuxMin ||
    lightLux > plant.lightLuxMax) {
  return RiskStatus.waspada;  // Warning
}

return RiskStatus.aman;  // Safe
```

## 🔄 Navigation Quick Ref

```dart
// Go to screen
context.go('/dashboard');
context.go('/monitoring');
context.go('/control');
context.go('/history');
context.go('/device-profile');

// Push modal
context.push('/device-profile');

// Go back
context.pop();
```

## 📝 Bahasa Indonesia UI Text Reference

| English | Bahasa Indonesia |
|---------|-----------------|
| Home | Beranda |
| Monitoring | Monitoring |
| Settings | Kontrol |
| History | Riwayat |
| Active Plant | Tanaman Aktif |
| Category | Kategori |
| Soil Moisture | Kelembaban Tanah |
| Light Intensity | Intensitas Cahaya |
| Risk Status | Status Risiko |
| Recommendations | Rekomendasi |
| Pump | Pompa Air |
| UV Lamp | Lampu UV |
| Ideal Range | Rentang Ideal |
| Safe | Aman |
| Warning | Waspada |
| High Risk | Risiko Tinggi |

## 🐛 Debugging Tips

```dart
// Print debug info
debugPrint('Device: ${deviceState.deviceId}');

// Watch provider value
ref.listen(activePlantProvider, (prev, next) {
  debugPrint('Plant changed: ${next.name}');
});

// Access current user
final user = ref.watch(currentUserProvider);
```

## ⚡ Performance Tips

- Use `ref.select()` to watch specific provider fields
- Avoid rebuilds with `const` widgets
- Use `ListView.builder` for long lists
- Memoize expensive computations with `Provider`
- Use `.when()` for async data handling

## 🧪 Testing Common Scenarios

### Test Active Plant Switching
1. Open Beranda
2. Tap different plants
3. Verify all screens show correct plant

### Test Risk Status
1. Arrange sensor values
2. Verify Risiko Tinggi when: moisture > 80% AND light < 300 lux
3. Check smart explanation text updates

### Test Manual/Auto Mode
1. Switch to Kontrol
2. Toggle mode
3. Verify buttons enable/disable correctly
4. Test confirmation dialogs

## 📚 File Navigation Shortcuts

| Task | File Location |
|------|---------------|
| Change theme colors | `lib/core/theme/app_theme.dart` |
| Update routing | `lib/core/router/app_router.dart` |
| Modify dashboard | `lib/features/dashboard/presentation/pages/dashboard_page.dart` |
| Adjust thresholds | `lib/features/dashboard/domain/models/device_state.dart` |
| Change risk logic | Search `RiskStatus` enum or `_getExplanation()` |
| Add UI component | `lib/shared/widgets/` |
| Manage state | `lib/features/[feature]/providers/` |

## 🔗 Useful Links

- Flutter Docs: https://flutter.dev
- Riverpod Docs: https://riverpod.dev
- Firebase Flutter: https://firebase.flutter.dev
- Go Router: https://pub.dev/packages/go_router
- Material Design 3: https://m3.material.io

## Emergency Fixes

```bash
# Clean everything
flutter clean && flutter pub get

# Rebuild dependencies
flutter pub upgrade

# Fix build issues
flutter pub cache clean && flutter pub get

# Check for errors
flutter analyze

# Format code
dart format lib/ -r
```

## 💡 Pro Tips

1. **Plants-First Thinking**: Always remember the active plant context
2. **Status Consistency**: Always show plant-specific ranges on detail screens
3. **Smart Text**: Never say "disease detected", use "indikasi risiko"
4. **Responsive Design**: Test on different screen sizes
5. **Bahasa First**: Keep UI text in Indonesian for consistency
6. **Error Handling**: Always provide user-friendly error messages
7. **Loading States**: Always show loading indicator for async operations

---

**Last Updated**: March 30, 2026
