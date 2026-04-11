import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';

// This would typically come from shared preferences or user profile
final deviceIdProvider = StateProvider<String>((ref) {
  return 'device_001'; // Demo device ID
});

final deviceStateProvider = StreamProvider<DeviceState?>((ref) async* {
  final deviceId = ref.watch(deviceIdProvider);

  // For demo purposes, yield a default state
  // In production, this would stream from Firebase Realtime Database
  yield DeviceState(
    deviceId: deviceId,
    soilMoisture: 65,
    lightLux: 4500,
    riskStatus: RiskStatus.aman,
    mode: Mode.otomatis,
    pumpStatus: false,
    uvLampStatus: false,
    lastUpdated: DateTime.now(),
    isConnected: true,
  );

  // Stream from Firebase - commented for now as it requires proper setup
  // yield* service.streamDeviceState(deviceId).map((data) {
  //   if (data == null) return null;
  //   return DeviceState(
  //     deviceId: deviceId,
  //     soilMoisture: data['soilMoisture'] ?? 0,
  //     lightLux: data['lightLux'] ?? 0,
  //     riskStatus: _parseRiskStatus(data['riskStatus']),
  //     mode: _parseMode(data['mode']),
  //     pumpStatus: data['pumpStatus'] ?? false,
  //     uvLampStatus: data['uvLampStatus'] ?? false,
  //     lastUpdated: DateTime.now(),
  //     isConnected: true,
  //   );
  // });
});
