enum RiskStatus { aman, waspada, risikoTinggi }

enum Mode { otomatis, manual }

extension RiskStatusExt on RiskStatus {
  String get display {
    switch (this) {
      case RiskStatus.aman:
        return 'Aman';
      case RiskStatus.waspada:
        return 'Waspada';
      case RiskStatus.risikoTinggi:
        return 'Risiko Tinggi';
    }
  }

  String get description {
    switch (this) {
      case RiskStatus.aman:
        return 'Kondisi tanaman aman dan optimal';
      case RiskStatus.waspada:
        return 'Kondisi mulai tidak ideal, perlu perhatian';
      case RiskStatus.risikoTinggi:
        return 'Kondisi kritis, risiko penyakit meningkat';
    }
  }
}

extension ModeExt on Mode {
  String get display {
    switch (this) {
      case Mode.otomatis:
        return 'Otomatis';
      case Mode.manual:
        return 'Manual';
    }
  }
}

class DeviceState {
  final String deviceId;
  final int soilMoisture; // 0-100%
  final int lightLux;
  final RiskStatus riskStatus;
  final Mode mode;
  final bool pumpStatus;
  final bool uvLampStatus;
  final DateTime lastUpdated;
  final bool isConnected;

  DeviceState({
    required this.deviceId,
    required this.soilMoisture,
    required this.lightLux,
    required this.riskStatus,
    required this.mode,
    required this.pumpStatus,
    required this.uvLampStatus,
    required this.lastUpdated,
    required this.isConnected,
  });

  DeviceState copyWith({
    String? deviceId,
    int? soilMoisture,
    int? lightLux,
    RiskStatus? riskStatus,
    Mode? mode,
    bool? pumpStatus,
    bool? uvLampStatus,
    DateTime? lastUpdated,
    bool? isConnected,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      lightLux: lightLux ?? this.lightLux,
      riskStatus: riskStatus ?? this.riskStatus,
      mode: mode ?? this.mode,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      uvLampStatus: uvLampStatus ?? this.uvLampStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  static String getSoilStatusText(int soilMoisture, int min, int max) {
    if (soilMoisture < min) return 'Terlalu Kering';
    if (soilMoisture > max) return 'Terlalu Lembap';
    return 'Ideal';
  }

  static String getLightStatusText(int lightLux, int min, int max) {
    if (lightLux < min) return 'Terlalu Rendah';
    if (lightLux > max) return 'Terlalu Tinggi';
    return 'Ideal';
  }

  static String getPumpStatusText(bool isOn) => isOn ? 'Menyala' : 'Mati';

  static String getUVStatusText(bool isOn) => isOn ? 'Menyala' : 'Mati';
}
