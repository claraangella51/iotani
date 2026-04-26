import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotani_berhasil/core/firebase/firebase_service.dart';
import 'package:iotani_berhasil/features/auth/providers/auth_provider.dart';
import 'package:iotani_berhasil/features/dashboard/domain/models/device_state.dart';

// This would typically come from shared preferences or user profile
final deviceIdProvider = StateProvider<String>((ref) {
  return 'device_001';
});

final deviceStateProvider = StreamProvider<DeviceState?>((ref) async* {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  if (user == null) {
    yield null;
    return;
  }

  final deviceId = ref.watch(deviceIdProvider);
  final service = FirebaseService();

  yield* service
      .streamDeviceState(deviceId)
      .map((data) {
        if (data == null) {
          return null;
        }

        final lastUpdatedRaw = data['lastUpdated'];
        final lastUpdated = _parseTimestamp(lastUpdatedRaw);

        return DeviceState(
          deviceId: (data['deviceId'] as String?) ?? deviceId,
          soilMoisture: _toInt(data['soilMoisture'] ?? data['kelembapan']),
          lightLux: _toInt(data['lightLux'] ?? data['cahaya']),
          riskStatus: _parseRiskStatus(data['riskStatus'] as String?),
          mode: _parseMode(data['mode'] as String?),
          pumpStatus: _toBool(data['pumpStatus'] ?? data['pompa']),
          uvLampStatus: _toBool(data['uvLampStatus'] ?? data['lampu']),
          lastUpdated: lastUpdated,
          isConnected: data['isConnected'] != false,
        );
      })
      .handleError((_, __) {
        // Ignore transient stream errors during auth state transitions.
      });
});

final modeStateProvider = Provider<String>((ref) {
  final deviceState = ref.watch(deviceStateProvider).value;
  return deviceState?.mode == Mode.manual ? 'manual' : 'otomatis';
});

RiskStatus _parseRiskStatus(String? value) {
  switch (value) {
    case 'warning':
    case 'waspada':
      return RiskStatus.waspada;
    case 'danger':
    case 'risiko_tinggi':
    case 'risikoTinggi':
      return RiskStatus.risikoTinggi;
    default:
      return RiskStatus.aman;
  }
}

Mode _parseMode(String? value) {
  switch (value) {
    case 'manual':
      return Mode.manual;
    case 'auto':
    case 'otomatis':
    default:
      return Mode.otomatis;
  }
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return int.tryParse('$value') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'on' || normalized == 'true' || normalized == '1';
  }
  return false;
}

DateTime _parseTimestamp(dynamic value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }

    final epoch = int.tryParse(value);
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    }
  }
  return DateTime.now();
}
