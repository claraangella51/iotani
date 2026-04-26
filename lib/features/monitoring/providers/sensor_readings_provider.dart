import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/firebase/firebase_service.dart';
import 'package:iotani_berhasil/features/auth/providers/auth_provider.dart';
import 'package:iotani_berhasil/features/monitoring/domain/models/sensor_reading.dart';
import 'package:iotani_berhasil/features/dashboard/providers/device_state_provider.dart';

final sensorReadingsProvider = StreamProvider<List<SensorReading>>((
  ref,
) async* {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  if (user == null) {
    yield const <SensorReading>[];
    return;
  }

  final deviceId = ref.watch(deviceIdProvider);
  final service = FirebaseService();

  yield* service
      .streamRecentReadings(deviceId)
      .map((readings) => readings)
      .handleError((_, __) {
        // Ignore transient stream errors during auth state transitions.
      });
});

final latestSensorReadingProvider = Provider<SensorReading?>((ref) {
  final readings = ref.watch(sensorReadingsProvider).value;
  return readings?.isNotEmpty ?? false ? readings!.first : null;
});
