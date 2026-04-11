import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/features/monitoring/domain/models/sensor_reading.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';

final sensorReadingsProvider = StreamProvider<List<SensorReading>>((
  ref,
) async* {
  final deviceId = ref.watch(deviceIdProvider);

  // For demo, yield sample data
  yield [
    SensorReading(
      id: '1',
      deviceId: deviceId,
      soilMoisture: 65,
      lightLux: 4500,
      riskStatus: 'aman',
      timestamp: DateTime.now(),
    ),
    SensorReading(
      id: '2',
      deviceId: deviceId,
      soilMoisture: 62,
      lightLux: 4200,
      riskStatus: 'aman',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SensorReading(
      id: '3',
      deviceId: deviceId,
      soilMoisture: 68,
      lightLux: 4800,
      riskStatus: 'aman',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // Stream from Firebase in production
  // yield* service.streamRecentReadings(deviceId).map((readings) {
  //   return readings
  //       .map((r) => SensorReading.fromJson(r))
  //       .toList();
  // });
});

final latestSensorReadingProvider = Provider<SensorReading?>((ref) {
  final readings = ref.watch(sensorReadingsProvider).value;
  return readings?.isNotEmpty ?? false ? readings!.first : null;
});
